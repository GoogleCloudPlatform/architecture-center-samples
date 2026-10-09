# OAuth client files (`scripts/secrets/`)

Put the Google **web application OAuth client** JSON for each system here. The deployment scripts
read them, so you never copy a client ID or secret by hand.

Everything in this directory except this README is git-ignored (`.gitignore`). The files contain a
`client_secret`: never commit them, paste them into a chat, or leave them readable by others
(`chmod 600 scripts/secrets/*.json`).

## What the file is

One OAuth 2.0 client per system, of type **Web application**. It is what Gemini Enterprise uses to
sign users in, and the Toolbox only trusts tokens issued to this client. It cannot be created from the
command line:

1. Open **APIs & Services > Credentials** in the Cloud console for your project.
2. **Create credentials > OAuth client ID > Web application**.
3. Add both authorized redirect URIs:
   - `https://vertexaisearch.cloud.google.com/oauth-redirect`
   - `https://vertexaisearch.cloud.google.com/static/oauth/oauth.html`
4. Create it, choose **Download JSON**, and save it here.

`./scripts/setup_oauth_client.sh` prints these steps and validates the downloaded files (it checks
for a top-level `web` key, `client_id`, `client_secret` and the redirect URIs).

## Naming: start the file name with the system

Console downloads are named `client_secret_<id>.apps.googleusercontent.com.json`. Prefix the name so
the scripts can tell the systems apart:

| System | Prefix | Example |
|---|---|---|
| EBS | `ebs` | `ebs_client_secret_123-abc.apps.googleusercontent.com.json` |
| PeopleSoft | `ps` or `peoplesoft` | `ps_client_secret_123-abc.apps.googleusercontent.com.json` |
| JD Edwards | `jde` | `jde_client_secret_123-abc.apps.googleusercontent.com.json` |

Any suffix works. The lookup is `scripts/secrets/<prefix>*.json`.

## Who reads them

| Script | Uses | For |
|---|---|---|
| `deploy_mcp_server.sh --system X` | `client_id` | proposes `GOOGLE_CLIENT_ID` for `<system>/.env` when it is blank |
| `setup_oauth_client.sh` | the whole file | validation |

The client secret is never written to an env file, a command line or runtime configurations.

## When there are several files

If more than one file matches a system, the scripts list them and ask which one to use. Keep one
client per system and project, and delete files for clients you no longer use.
