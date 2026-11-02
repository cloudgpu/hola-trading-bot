#!/usr/bin/env bash
# Compile and run the GrokTrader hola-cc agent.
# Usage:
#   ./agent-run.sh                                # defaults below
#   ./agent-run.sh symbol=ETH-USD checks=5 interval_seconds=30
#   SYMBOL=ETH-USD CHECKS=5 ./agent-run.sh
# Env overrides: SYMBOL CHECKS INTERVAL ALERT RISK CONF HOLACC
set -euo pipefail
cd "$(dirname "$0")"

HOLACC="${HOLACC:-holacc}"
SYMBOL="${SYMBOL:-BTC-USD}"
CHECKS="${CHECKS:-10}"
INTERVAL="${INTERVAL:-60}"
ALERT="${ALERT:-0.5}"
RISK="${RISK:-1.0}"
CONF="${CONF:-70.0}"

echo "==> Checking grok_trader.hl with ${HOLACC}"
"${HOLACC}" check grok_trader.hl

echo "==> Building ./grok_trader"
"${HOLACC}" build grok_trader.hl -o grok_trader

echo "==> Running: symbol=${SYMBOL} checks=${CHECKS} interval=${INTERVAL} alert=${ALERT} risk=${RISK} conf=${CONF}"
if [ "$#" -gt 0 ]; then
  ./grok_trader "$@"
else
  ./grok_trader symbol="${SYMBOL}" checks="${CHECKS}" interval_seconds="${INTERVAL}" alert_percent="${ALERT}" max_risk_pct="${RISK}" min_confidence="${CONF}"
fi
