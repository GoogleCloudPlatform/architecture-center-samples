#!/usr/bin/env python3
"""Print a Google ID token whose audience is the Toolbox's OAuth client ID.

Used by mcp_toolbox_bridge.sh for the Toolbox `google-auth` authService, which
needs `aud` = the client ID and the signed-in user's email (gcloud cannot mint
that for a user account). Stdlib only. The ID token goes to stdout; everything
else goes to stderr.

First run: opens a browser (authorization code flow with PKCE) and caches the
refresh token in ~/.config/oracle-mcp-1p/ (mode 600, outside the repo). Later
runs refresh silently.

  google_login.py --client-id ID [--client-json FILE] [--redirect-uri URI] [--force-login]

The redirect URI must be registered on the OAuth client; the default is
http://ebs-mcp.com:8085/oauth2callback (ebs-mcp.com resolves to 127.0.0.1 via /etc/hosts).
"""
import argparse
import base64
import glob
import hashlib
import json
import os
import secrets
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer

AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
TOKEN_URL = "https://oauth2.googleapis.com/token"
DEFAULT_REDIRECT = "http://ebs-mcp.com:8085/oauth2callback"
CACHE_DIR = os.path.expanduser("~/.config/oracle-mcp-1p")
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def log(msg):
    print(f"[google_login] {msg}", file=sys.stderr)


def find_client_json(client_id, explicit):
    candidates = [explicit] if explicit else []
    for d in (os.path.join(SCRIPT_DIR, "secrets"), SCRIPT_DIR, os.path.dirname(SCRIPT_DIR)):
        candidates += glob.glob(os.path.join(d, "*client_secret*.json"))
    for path in candidates:
        try:
            with open(path) as f:
                data = json.load(f)
            conf = data.get("web") or data.get("installed") or {}
            if conf.get("client_id") == client_id:
                return conf
        except (OSError, ValueError):
            continue
    return None


def post_token(params):
    req = urllib.request.Request(TOKEN_URL, data=urllib.parse.urlencode(params).encode())
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        try:
            detail = json.load(e).get("error_description", "")
        except ValueError:
            detail = ""
        raise RuntimeError(f"token endpoint HTTP {e.code}: {detail}")


def token_valid(id_token, skew=120):
    try:
        p = id_token.split(".")[1]
        claims = json.loads(base64.urlsafe_b64decode(p + "=" * (-len(p) % 4)))
        return claims.get("exp", 0) - time.time() > skew
    except (IndexError, ValueError):
        return False


def browser_login(conf, redirect_uri):
    parsed = urllib.parse.urlparse(redirect_uri)
    verifier = secrets.token_urlsafe(64)
    challenge = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).rstrip(b"=").decode()
    state = secrets.token_urlsafe(16)
    result = {}

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            u = urllib.parse.urlparse(self.path)
            if u.path != parsed.path:
                self.send_response(404)
                self.end_headers()
                return
            q = urllib.parse.parse_qs(u.query)
            if q.get("state", [""])[0] != state:
                result["error"] = "state mismatch"
            elif "error" in q:
                result["error"] = q["error"][0]
            else:
                result["code"] = q.get("code", [""])[0]
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Signed in. You can close this tab." if "code" in result else b"Sign-in failed; see the terminal.")

        def log_message(self, *a):
            pass

    # The redirect host resolves to loopback (hosts entry); bind loopback only.
    server = HTTPServer(("127.0.0.1", parsed.port or 80), Handler)
    server.timeout = 1
    url = AUTH_URL + "?" + urllib.parse.urlencode({
        "client_id": conf["client_id"], "redirect_uri": redirect_uri, "response_type": "code",
        "scope": "openid email", "state": state, "code_challenge": challenge,
        "code_challenge_method": "S256", "access_type": "offline", "prompt": "consent",
    })
    log("Opening browser to sign in. If it does not open, visit:\n" + url)
    webbrowser.open(url)
    deadline = time.time() + 300
    while not result and time.time() < deadline:
        server.handle_request()
    server.server_close()
    if "code" not in result:
        raise RuntimeError(result.get("error", "timed out waiting for sign-in"))
    return post_token({
        "grant_type": "authorization_code", "code": result["code"], "redirect_uri": redirect_uri,
        "client_id": conf["client_id"], "client_secret": conf.get("client_secret", ""),
        "code_verifier": verifier,
    })


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--client-id", required=True)
    ap.add_argument("--client-json")
    ap.add_argument("--redirect-uri", default=os.environ.get("MCP_OAUTH_REDIRECT", DEFAULT_REDIRECT))
    ap.add_argument("--force-login", action="store_true")
    args = ap.parse_args()

    conf = find_client_json(args.client_id, args.client_json)
    if not conf:
        log(f"No *client_secret*.json for {args.client_id} in scripts/secrets/ (pass --client-json).")
        return 2

    os.makedirs(CACHE_DIR, mode=0o700, exist_ok=True)
    cache_path = os.path.join(CACHE_DIR, f"{args.client_id.split('.')[0]}.json")
    cache = {}
    try:
        with open(cache_path) as f:
            cache = json.load(f)
    except (OSError, ValueError):
        pass

    if not args.force_login and cache.get("id_token") and token_valid(cache["id_token"]):
        print(cache["id_token"])
        return 0

    tok = None
    if not args.force_login and cache.get("refresh_token"):
        try:
            tok = post_token({
                "grant_type": "refresh_token", "refresh_token": cache["refresh_token"],
                "client_id": conf["client_id"], "client_secret": conf.get("client_secret", ""),
            })
        except RuntimeError as e:
            log(f"Refresh failed ({e}); signing in again.")
    if tok is None:
        try:
            tok = browser_login(conf, args.redirect_uri)
        except (RuntimeError, OSError) as e:
            log(f"Login failed: {e}")
            return 1

    id_token = tok.get("id_token")
    if not id_token:
        log("Google returned no id_token.")
        return 1
    new_cache = {"refresh_token": tok.get("refresh_token") or cache.get("refresh_token"), "id_token": id_token}
    fd = os.open(cache_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump(new_cache, f)
    print(id_token)
    return 0


if __name__ == "__main__":
    sys.exit(main())
