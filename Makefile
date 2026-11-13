# CopperLedRing. Each target is a plain `copper` call, written out in full;
# `copper <command> --help` explains every option. Nothing here needs KiCad.
#
# COPPER is the compiler pinned in .copper-version: build it in the CopperScript
# checkout (cargo build --release --locked -p copper) or pass COPPER=copper.
COPPER ?= ../CopperScript/target/release/copper
SHELL := bash
.NOTPARALLEL:
.PHONY: check si-check layout route render review bom assembly-update order

# KiCad cross-check, off by default: make route order KICAD=1 (kicad-cli on PATH).
VERIFY := $(if $(KICAD),--verify kicad)
EXPORT := $(if $(KICAD),--drc kicad --plotter kicad)

# Fabrication preset and router settings are in the board's `build` block;
# an option after `--` on a call overrides it.

# Every route is a new build/board/<UTC time>-<pid>/ with a run.json; RUN is the newest.
RUN = $(patsubst %/run.json,%,$(lastword $(sort $(wildcard build/board/[0-9]*/run.json))))

check:
	$(COPPER) check board.copper --locked

si-check:
	$(COPPER) si-check board.copper --locked --offline

layout:
	$(COPPER) plan-layout board.copper --locked --candidates 1 -o build/board/placed.kicad_pcb --report build/board/placement.json

route:
	$(COPPER) build board.copper --locked $(VERIFY)

render:
	rm -rf $(RUN)/plot && $(COPPER) plot $(RUN)/board.kicad_pcb -o $(RUN)/plot
	$(COPPER) render $(RUN)/plot --layer F.Cu --layer Edge.Cuts -o $(RUN)/front.svg
	$(COPPER) render $(RUN)/plot --layer B.Cu --layer Edge.Cuts -o $(RUN)/back.svg

review:
	uv run --project ../CopperReview copper-review $(RUN)/board.kicad_pcb --project . --entry board.copper --source board.copper

bom:
	$(COPPER) assembly check board.copper --locked --offline --lock assembly.lock
	$(COPPER) assembly bom board.copper --locked --offline --lock assembly.lock -o build/order/bom.csv --hand-assembly build/order/hand-assembly.csv --ordering build/order/ordering.csv

assembly-update:
	$(COPPER) assembly update board.copper --locked --offline --lock assembly.lock

# JLCPCB package from the newest route. The export refuses a route that did not
# pass or predates a source change, refills and checks the board itself, and is
# not independently CAM-qualified.
order: bom
	$(COPPER) export-manufacturing $(RUN)/board.kicad_pcb --run $(RUN)/run.json $(EXPORT) --skip-independent-cam --bom build/order/bom.csv --replace -o build/order/jlcpcb
