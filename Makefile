# No project-local design algorithms: CopperScript and KiCad own the build.
.DEFAULT_GOAL := all
.NOTPARALLEL:
UV ?= uv
KICAD_CLI ?= kicad-cli
FOOTPRINT_ROOT ?= /usr/share/kicad/footprints
BOARD := board.copper
BUILD := build
PCB := $(BUILD)/board.kicad_pcb

.PHONY: all fetch check pcb route render verify order
all: route verify render

fetch:
	$(UV) sync --locked
	$(UV) run --locked copper check $(BOARD) --locked

check: fetch
	$(UV) run --locked copper check $(BOARD) --locked --offline

pcb: check
	$(UV) run --locked copper export-kicad-pcb $(BOARD) --locked --offline --footprint-root "$(FOOTPRINT_ROOT)" -o $(PCB)

route: check
	$(UV) run --locked python -c "from pathlib import Path; Path('$(BUILD)').mkdir(exist_ok=True)"
	$(UV) run --locked python -m cProfile -o $(BUILD)/route.pstats -m copperscript route-board $(BOARD) --locked --offline --layers 2 --candidates 1 --footprint-root "$(FOOTPRINT_ROOT)" --pitch-mm 0.5 --passes 3 --search-budget 50000 --fanout --fanout-maze --soft-ripup --constrained-pins-first --progressive-guides --early-plane-stitch --stitch-surface-zones --plane-stitch-radius-mm 5 --plane-contact-radius-mm 8 --plane-stitch-detour-mm 3 --package-access-trials 0 --zone-escape-trials 0 --zone-local-ripup-trials 0 --progress --verify-plane-fill "$(KICAD_CLI)" --report $(BUILD)/route.json -o $(PCB)

render:
	"$(KICAD_CLI)" pcb export svg --layers F.Cu,B.Cu --common-layers Edge.Cuts --mode-multi --fit-page-to-board --exclude-drawing-sheet --check-zones -o $(BUILD)/layers/ $(PCB)

verify:
	"$(KICAD_CLI)" pcb drc --refill-zones --save-board --format json --severity-all --exit-code-violations -o $(BUILD)/drc.json $(PCB)
	$(UV) run --locked python -c "import json; r=json.load(open('$(BUILD)/drc.json')); assert not r['violations'] and not r['unconnected_items'], 'Board still has DRC violations or unrouted connections'"

# Deliberately fail closed until both CAM and assembly release gates exist.
order: all
	$(UV) run --locked python -c "raise SystemExit('NOT ORDER-READY: circular CAM qualification, orderable BOM/CPL and firmware release remain outstanding. See README.md.')"
