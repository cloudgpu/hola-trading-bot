# hola-trading-bot

Continuous crypto price monitor written in hola-cc. It checks a symbol on a
schedule, narrates every step of its calculation, and emits BUY, SELL, or HOLD
signals. Paper only: it never touches real money.

## How it works

The bot mirrors the xAI Grok function-calling pattern: the model is the brain,
local tools are the hands.

- `get_price` fetches the live spot price from Coinbase (`http` tool, no key).
- `narrate` prints a verbose trace line for every calculation step (`print`
  tool, so output reaches the terminal).
- `emit_signal` prints a formatted signal banner on screen.
- `record_signal` appends the signal to `SIGNALS.log`.
- `log_trade` appends a journal line to `TRADE_LOG.md`.
- `place_order` is a stub that only logs `PAPER_ORDER`. Wire real execution
  behind it yourself.
- `wait` sleeps between checks.

Each check follows the same pipeline:

1. PRICE: call `get_price`, narrate the raw JSON and the parsed amount.
2. MOVE: `pct = (current - previous) / previous * 100`. Narrate both prices
   and the math, plus the move versus the first price.
3. CONFIDENCE 0-100: start 50, +20 if the move is at least twice the alert
   threshold, +10 if the direction repeats, -20 if the move is below the
   alert threshold, -15 on a whipsaw (direction flip). Each adjustment is
   narrated.
4. DECISION: BUY on an up-move at or above the alert threshold, SELL on a
   down-move at or above it, otherwise HOLD. BUY and SELL additionally
   require confidence at or above the minimum. The rule that fired is
   narrated.
5. SIZE: quantity is sized so a 2 percent adverse move loses no more than the
   configured max risk percent. Paper only.

Note on output visibility in hola-cc: `sh` tool stdout goes back to the model,
not the terminal. Only `print` reaches the screen. That is why narration and
signal banners use `print`, while file logging uses `sh`.

## Requirements

- hola-cc compiler (`holacc`) on PATH, or set `HOLACC` to its path.
- An LLM provider configured for the compiled binary (it uses your default
  Hola profile at runtime). No API keys are stored in this repo.
- Network access to `api.coinbase.com` for prices.

## Build

    make check
    make

This produces the `grok_trader` binary.

## Run

    ./grok_trader symbol=BTC-USD checks=10 interval_seconds=60 alert_percent=0.5 max_risk_pct=1.0 min_confidence=70.0

Parameters:

- `symbol`: trading pair, for example `BTC-USD` or `ETH-USD`.
- `checks`: how many price checks to make.
- `interval_seconds`: seconds between checks.
- `alert_percent`: the move in percent that deserves a BUY or SELL signal.
- `max_risk_pct`: max risk percent per trade, used for paper sizing.
- `min_confidence`: minimum confidence (0-100) for BUY or SELL, else HOLD.

Example output:

      PRICE check 1: raw JSON {...} parsed amount = 77625.055 USD
      MOVE check 1: ...
      CONFIDENCE check 1: ...
      DECISION check 1: ...
    ----------------------------------------
     SIGNAL HOLD: HOLD BTC-USD @ 77625.055 | ...
    ----------------------------------------

The run also appends to `SIGNALS.log` and `TRADE_LOG.md`, and ends with one
line of JSON (`first`, `last`, `low`, `high`, `signals`, `checks_done`,
`summary`).

## Files

- `grok_trader.hl`: the skill (tools) and agent (monitor loop) source.
- `Makefile`: `check`, `build`, `agents`, `clean` targets.

## Safety

This bot is paper only. `place_order` logs intent and places nothing. Do not
connect real exchange keys or real order execution without your own risk
controls, position limits, and testing.

## Attribution

Built with the Hola coding agent (`hola-coder`), which generated the hola-cc
skill and agent source, the Makefile, and this README.

## License

MIT. See `LICENSE`.
