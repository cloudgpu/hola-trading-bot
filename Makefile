HOLACC ?= holacc

.PHONY: all check agents clean

all: grok_trader

grok_trader: grok_trader.hl
	$(HOLACC) build $< -o $@

check:
	$(HOLACC) check grok_trader.hl

agents:
	$(HOLACC) agents grok_trader.hl

clean:
	rm -f grok_trader
