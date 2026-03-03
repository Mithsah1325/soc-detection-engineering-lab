#!/bin/bash

set -euo pipefail

usage() {
	echo "Usage: sudo $0 <ip_address>"
	echo "Example: sudo $0 192.168.1.101"
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
	usage
	exit 0
fi

if [[ $# -ne 1 ]]; then
	usage
	exit 1
fi

IP="$1"

if ! [[ "$IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
	echo "Error: invalid IPv4 address format: $IP"
	exit 1
fi

if [[ $EUID -ne 0 ]]; then
	echo "Error: run as root (or with sudo)."
	exit 1
fi

if ! command -v iptables >/dev/null 2>&1; then
	echo "Error: iptables is not installed or not in PATH."
	exit 1
fi

iptables -C INPUT -s "$IP" -j DROP 2>/dev/null || iptables -A INPUT -s "$IP" -j DROP
echo "[+] IP address $IP is blocked in INPUT chain."
