#!/bin/bash

YELLOW='\033[1;33m'
RESET='\033[0m'

if [ ! -x "$HOME/.local/bin/aikido-local-scanner" ]; then
    echo -e "${YELLOW}Aikido Local Scanner is missing. Find install instructions at https://help.aikido.dev/code-scanning/local-code-scanning/aikido-secrets-pre-commit-hook${RESET}"
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
"$HOME/.local/bin/aikido-local-scanner" pre-commit-scan "$REPO_ROOT"
