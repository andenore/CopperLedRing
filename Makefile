# No project-local design algorithms: CopperScript and KiCad own the build.
.DEFAULT_GOAL := all
.NOTPARALLEL:
UV ?= uv
ifeq ($(OS),Windows_NT)
KICAD_CLI ?= $(ProgramW6432)/KiCad/10.0/bin/kicad-cli.exe
FOOTPRINT_ROOT ?= $(ProgramW6432)/KiCad/10.0/share/kicad/footprints
else
KICAD_CLI ?= kicad-cli
FOOTPRINT_ROOT ?= /usr/share/kicad/footprints
endif
BOARD := board.copper
BUILD := build
PCB := $(BUILD)/board.kicad_pcb
EDITOR_PYTHON ?= $(UV) run --locked python
EDITOR_ARGS ?=
REVIEW_COPPER ?=
REVIEW_DIR ?= $(BUILD)/autonomous-review
REVIEW_PROFILE ?= balanced

.PHONY: all fetch check pcb edit route route-review render verify assembly manufacturing order
all: manufacturing render

fetch:
	$(UV) sync --locked
	$(UV) run --locked copper check $(BOARD) --locked

check: fetch
	$(UV) run --locked copper check $(BOARD) --locked --offline

pcb: check
	$(UV) run --locked copper export-kicad-pcb $(BOARD) --locked --offline --footprint-root "$(FOOTPRINT_ROOT)" -o $(PCB)

# Shared CopperScript editor; source edits use explicit diff review and Save.
edit: fetch
	$(EDITOR_PYTHON) -m copperscript edit-mechanical $(BOARD) --locked --offline --layers 2 --footprint-root "$(FOOTPRINT_ROOT)" $(EDITOR_ARGS)

# Retained pinned build; review the shared solver without changing its lockfile.
route: pcb
	$(UV) run --locked python -c "from pathlib import Path; Path('$(BUILD)').mkdir(exist_ok=True)"
	$(UV) run --locked python -m cProfile -o $(BUILD)/route.pstats -m copperscript route-board $(BOARD) --locked --offline --layers 2 --candidates 1 --footprint-root "$(FOOTPRINT_ROOT)" --pitch-mm 0.5 --minimum-repair-pitch-mm 0.1 --passes 3 --search-budget 50000 --heuristic-weight 200 --fanout --fanout-maze --soft-ripup --constrained-pins-first --progressive-guides --early-plane-stitch --stitch-surface-zones --plane-stitch-radius-mm 5 --plane-contact-radius-mm 8 --plane-stitch-detour-mm 3 --package-access-trials 0 --zone-escape-trials 0 --zone-local-ripup-trials 0 --progress --verify-plane-fill "$(KICAD_CLI)" --report $(BUILD)/route.json -o $(PCB)

# Only design inputs and shared CLI options; no project-local routing algorithm.
route-review:
	$(if $(strip $(REVIEW_COPPER)),,$(error Set REVIEW_COPPER to a current CopperScript command; this target does not upgrade pinned dependencies))
	$(UV) run --locked python -c "from pathlib import Path; Path('$(REVIEW_DIR)').mkdir(parents=True, exist_ok=False)"
	$(REVIEW_COPPER) route-board $(BOARD) --locked --offline --layers 2 --footprint-root "$(FOOTPRINT_ROOT)" --routing-profile $(REVIEW_PROFILE) --pitch-mm 0.5 --fanout-maze --soft-ripup --constrained-pins-first --progressive-guides --stitch-surface-zones --plane-stitch-radius-mm 5 --plane-contact-radius-mm 8 --plane-stitch-detour-mm 3 --verify-plane-fill "$(KICAD_CLI)" --native-evidence-directory "$(REVIEW_DIR)/native" --report "$(REVIEW_DIR)/route.json" -o "$(REVIEW_DIR)/candidate.kicad_pcb" --progress

render:
	"$(KICAD_CLI)" pcb export svg --layers F.Cu,B.Cu --common-layers Edge.Cuts --mode-multi --fit-page-to-board --exclude-drawing-sheet --check-zones -o $(BUILD)/layers/ $(PCB)

verify:
	"$(KICAD_CLI)" pcb drc --refill-zones --save-board --format json --severity-all --exit-code-violations -o $(BUILD)/drc.json $(PCB)
	$(UV) run --locked python -c "import json; r=json.load(open('$(BUILD)/drc.json')); assert not r['violations'] and not r['unconnected_items'], 'Board still has DRC violations or unrouted connections'"

assembly: check
	$(UV) run --locked copper assembly check $(BOARD) --locked --offline --lock assembly.lock --report $(BUILD)/assembly.json
	$(UV) run --locked copper assembly bom $(BOARD) --locked --offline --lock assembly.lock -o $(BUILD)/bom.csv

# Native DRC is required; independent CAM qualification is explicitly skipped.
# No firmware or order submission. Existing successful exports are backed up.
manufacturing: assembly route verify
	$(UV) run --locked copper export-manufacturing $(PCB) --kicad-cli "$(KICAD_CLI)" --skip-independent-cam --bom $(BUILD)/bom.csv --replace -o $(BUILD)/manufacturing

order: all
	$(UV) run --locked python -c "print('Files: $(BUILD)/manufacturing. Upload gerbers-drill.zip, bom.csv and cpl.csv. Check supplier stock, BOM matching and assembly polarity/rotation preview before ordering. Firmware and battery cell are not included.')"
