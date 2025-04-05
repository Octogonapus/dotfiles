#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

USAGE="Usage: $0 [options] EMAIL_FILE

DESCRIPTION
    Extracts the HTML part of an email file and opens it in a browser.

OPTIONS
    --out (string, required)
    The final path to save the file.

    --browser (string)
    A path to a web browser which will open the file.
    If not set, the file will not be opened.

    --wsl (flag)
    Indicates that this script is running inside WSL and that the browser and out paths are in Windows.
    The out path will first be mapped to a native Windows path before being opened in the browser."

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "$USAGE"
    exit
fi

TMP_DIR=$(mktemp -d)
TMP_HTML="$TMP_DIR/output.html"
TMP_BODY="$TMP_DIR/body.txt"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

main() {
    local EMAIL_FILE=""
    local BROWSER=""
    local OUTPATH=""
    local IS_WSL=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --browser)
                shift
                if [[ $# -eq 0 ]]; then
                    echo "Error: --browser requires a path argument."
                    echo "$USAGE"
                    exit 1
                fi
                BROWSER="$1"
                ;;
            --out)
                shift
                if [[ $# -eq 0 ]]; then
                    echo "Error: --out requires a path argument."
                    echo "$USAGE"
                    exit 1
                fi
                OUTPATH="$1"
                ;;
            --wsl)
                IS_WSL="1"
                ;;
            -*)
                echo "Unknown option: $1"
                echo "$USAGE"
                exit 1
                ;;
            *)
                EMAIL_FILE="$1"
                ;;
        esac
        shift
    done

    if [ -z "$EMAIL_FILE" ]; then
        echo "Error: EMAIL_FILE is a required parameter."
        echo "$USAGE"
        exit 1
    fi

    if [ -z "$OUTPATH" ]; then
        echo "Error: --out is a required option."
        echo "$USAGE"
        exit 1
    fi

    awk '
        BEGIN { in_html=0; encoding=""; body_file="'"$TMP_BODY"'" }
        tolower($0) ~ /^content-type: text\/html/ { in_html=1 }
        in_html && tolower($0) ~ /^content-transfer-encoding:/ {
            if ($0 ~ /base64/) encoding="base64";
            else if ($0 ~ /quoted-printable/) encoding="quoted-printable";
        }
        in_html && /^$/ {
            in_html=2
            next
        }
        in_html==2 {
            if ($0 ~ /^--/ || tolower($0) ~ /^content-type:/) {
            exit
            }
            print $0 >> body_file
        }
        END {
            print encoding > "'"$TMP_DIR/encoding.txt"'"
        }
    ' "$EMAIL_FILE"

    ENCODING=$(<"$TMP_DIR/encoding.txt")

    case "$ENCODING" in
        base64)
            base64 -d "$TMP_BODY" > "$TMP_HTML"
            ;;
        quoted-printable)
            perl -MMIME::QuotedPrint -ne 'print decode_qp($_)' "$TMP_BODY" > "$TMP_HTML"
            ;;
        *)
            cp "$TMP_BODY" "$TMP_HTML"
            ;;
    esac

    mv -f "$TMP_HTML" "$OUTPATH"
    if [ -n "$BROWSER" ]; then
        local BROWSER_OUTPATH="file://$OUTPATH"
        if [ "$IS_WSL" ]; then
            BROWSER_OUTPATH="file://$(wslpath -w "$OUTPATH")"
        fi
        "$BROWSER" "$BROWSER_OUTPATH"
    fi
}

main "$@"
