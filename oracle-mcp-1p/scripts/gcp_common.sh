#!/usr/bin/env bash
# ==============================================================================
# Shared GCP helpers for scripts/deploy_mcp_server.sh. Source it; do not execute.
#
# The sourcing script must set, BEFORE calling these helpers:
#   ENV_FILE    path of the shared .env file
#   ASSUME_YES  true|false   (--yes)
#   DRY_RUN     true|false   (--dry-run)
#   FIX_MODE    true|false   (--fix)
#   CLI_SET     " name name ..." - settings given on the command line (never treated as blank)
# Nothing here changes state without going through confirm().
# ==============================================================================

# Mask values of secret-looking env vars (KEY=value) before printing a command.
mask_secrets() {
    sed -E 's/([A-Za-z0-9_]*(SECRET|PASSWORD|PASSWD|TOKEN|API_?KEY|PRIVATE_?KEY)[A-Za-z0-9_]*=)[^, ]*/\1****/g' <<<"$1"
}

# ==============================================================================
# Confirmation gate: nothing that changes state runs without a 'yes'
# ==============================================================================
# Returns 0 if the user agrees (or --yes was given), 1 otherwise.
confirm() {
    local prompt="$1" reply
    [ "${ASSUME_YES}" = true ] && return 0
    if [ ! -t 0 ]; then
        echo "     ✖ Not confirmed: no interactive terminal (pass --yes to proceed non-interactively)" >&2
        return 1
    fi
    read -r -p "     ❓ ${prompt} [y/N] " reply || return 1
    [[ "${reply}" =~ ^[Yy]([Ee][Ss])?$ ]]
}



cli_set() { [[ "${CLI_SET}" == *" $1 "* ]]; }

# True if KEY is missing or empty in .env
env_blank() {
    [ -f "${ENV_FILE}" ] || return 0
    local v
    v=$(grep -E "^[[:space:]]*$1=" "${ENV_FILE}" | head -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true)
    [ -z "${v}" ]
}

# Set KEY="VALUE" in .env (replace the first active line, else append)
env_set() {
    python3 - "${ENV_FILE}" "$1" "$2" <<'PY'
import os, re, sys
path, key, val = sys.argv[1:4]
lines = open(path).read().splitlines() if os.path.exists(path) else []
pat = re.compile(r'^\s*' + re.escape(key) + r'=')
for i, line in enumerate(lines):
    if pat.match(line):
        lines[i] = f'{key}="{val}"'
        break
else:
    lines.append(f'{key}="{val}"')
open(path, 'w').write("\n".join(lines) + "\n")
PY
}

# Propose KEY=VALUE; the user may accept (y), decline (n/blank) or type their own value.
# The value finally chosen is left in OFFER_VALUE (callers must use it, not the proposal).
OFFER_VALUE=""
offer_save() {
    local key="$1" val="$2" reply
    OFFER_VALUE="${val}"
    echo "     ↳ proposed: ${key}=\"${val}\""
    if [ "${DRY_RUN}" = true ]; then echo "     [dry-run] not saved"; return 1; fi
    if [ "${ASSUME_YES}" = true ]; then
        env_set "${key}" "${val}"; echo "     💾 saved ${key} to ${ENV_FILE#${REPO_ROOT}/}"; return 0
    fi
    if [ ! -t 0 ]; then
        echo "     ✖ Not confirmed: no interactive terminal (pass --yes to proceed non-interactively)" >&2
        echo "     ⏭️  not saved - set ${key} in ${ENV_FILE} manually"
        return 1
    fi
    read -r -p "     ❓ Save ${key} to ${ENV_FILE#${REPO_ROOT}/}? [Y/n, or type your own value; Enter = yes] " reply || return 1
    case "${reply}" in
        ""|[Yy]|[Yy][Ee][Ss]) ;;
        [Nn]|[Nn][Oo])
            echo "     ⏭️  not saved - set ${key} in ${ENV_FILE} manually"
            return 1 ;;
        *) OFFER_VALUE="${reply}" ;;
    esac
    env_set "${key}" "${OFFER_VALUE}"
    echo "     💾 saved ${key}=\"${OFFER_VALUE}\" to ${ENV_FILE#${REPO_ROOT}/}"
}

# Pick one of several candidates (sets CHOICE). Fails when nothing is chosen.
# A choice is never auto-answered: --yes skips confirmations, but a value the user must pick
# (and that is not already in the env file or on the command line) is always asked when a terminal exists.
CHOICE=""
choose_from() {
    local prompt="$1" i reply; shift
    local items=("$@")
    CHOICE=""
    [ ${#items[@]} -gt 0 ] || return 1
    if [ ${#items[@]} -eq 1 ]; then
        if [ ! -t 0 ]; then
            echo "     ✖ no interactive terminal to confirm '${items[0]}' for: ${prompt} (set it in ${ENV_FILE#${REPO_ROOT}/} or on the command line)" >&2
            return 1
        fi
        read -r -p "     ❓ ${prompt}: use '${items[0]}'? [Y/n, or type your own value; Enter = yes] " reply || return 1
        case "${reply}" in
            ""|[Yy]|[Yy][Ee][Ss]) CHOICE="${items[0]}" ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) CHOICE="${reply}" ;;
        esac
        return 0
    fi
    if [ ! -t 0 ]; then
        echo "     ✖ ${#items[@]} candidates found; choose one interactively (or set it in ${ENV_FILE#${REPO_ROOT}/} / on the command line):" >&2
        printf '         - %s\n' "${items[@]}" >&2
        return 1
    fi
    echo "     ${prompt}:"
    for i in "${!items[@]}"; do echo "       $((i + 1))) ${items[$i]}"; done
    read -r -p "     Choose 1-${#items[@]}, or type your own value; n = skip [Enter = 1]: " reply || return 1
    [ -n "${reply}" ] || reply=1
    [[ "${reply}" =~ ^[Nn]([Oo])?$ ]] && return 1
    if [[ "${reply}" =~ ^[0-9]+$ ]] && [ "${reply}" -ge 1 ] && [ "${reply}" -le ${#items[@]} ]; then
        CHOICE="${items[$((reply - 1))]}"
    else
        CHOICE="${reply}"
    fi
}


# Ask before a state-changing step; always declined under --dry-run
approve() {
    if [ "${DRY_RUN}" = true ]; then echo "     [dry-run] would ask: $1"; return 1; fi
    confirm "$1"
}

# Run a state-changing command after confirmation (never under --dry-run)
do_change() {
    local desc="$1"; shift
    echo "     ↳ $*"
    if [ "${DRY_RUN}" = true ]; then echo "     [dry-run] not executed"; return 1; fi
    confirm "${desc}" || { echo "     ⏭️  skipped"; return 1; }
    "$@" >/dev/null
}


PF_FAIL=0
PF_WARN=0
pf_ok()   { echo "  ✅ $*"; }
pf_warn() { echo "  ⚠️  $*"; PF_WARN=$((PF_WARN + 1)); }
pf_fail() { echo "  ❌ $*"; PF_FAIL=$((PF_FAIL + 1)); }
pf_hint() { echo "     ↳ $*"; }
# Print a remediation command; with --fix, execute it (skipped under --dry-run).
# A fixed failure is reclassified from failure to fixed.
pf_remedy() {
    local severity="$1"; shift
    pf_hint "$*"
    [ "${FIX_MODE}" = true ] || return 0
    if [ "${DRY_RUN}" = true ]; then
        echo "     [dry-run] not executed"
    elif ! confirm "Run this fix?"; then
        echo "     ⏭️  skipped"
    elif "$@" >/dev/null 2>&1; then
        echo "     🔧 fixed"
        if [ "${severity}" = fail ]; then PF_FAIL=$((PF_FAIL - 1)); else PF_WARN=$((PF_WARN - 1)); fi
    else
        echo "     ✖ fix command failed"
    fi
}

