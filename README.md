# CopperLedRing

[![Board build](https://github.com/andenore/CopperLedRing/actions/workflows/build.yml/badge.svg)](https://github.com/andenore/CopperLedRing/actions/workflows/build.yml)

**A minimal [CopperScript](https://github.com/andenore/CopperScript) example
project and reusable board-project template.** It is also intended to be a
direct-order hardware proof of concept: take a qualified release's manufacturing
and assembly files, order the board, and try the design without writing your own
circuit first.

**Current ordering status: DRAFT — no order-ready release exists yet.**
The source and build are usable as a template now, but generated drafts must not
be submitted as an assembled-board order. The current circuit has illustrative
LED/passive selections, and CopperScript's
independent circular-outline CAM release gate is still closed. `make order`
fails closed; it never labels an inspection artifact as production-ready.

## The board

A 50 mm circular, two-layer board with an nRF52832 QFAA controlling twelve
active-low red LEDs, a rear Keystone 3034 CR2032 holder, a 10-pin SMD Cortex-M
SWD header, and bypass/LDO-support capacitors. This is an LED controller:
**Bluetooth is not fitted**, and there is no antenna or external crystal.

### Routed board — native DRC clean

These are renders of the actual GitHub-built KiCad inspection board, not a mockup
or a photograph of assembled hardware. The front has twelve LEDs around the
edge, their resistors just inside, the MCU to the left of centre and the SWD
connector above it. Both sides have GND pours with disconnected islands removed.
The mirrored rear view shows the battery holder and rear routes.
Fabrication labels are omitted on the front for readability.

| Front: routed copper, GND fill and silkscreen | Rear: mirrored routes, holder outline and GND fill |
| --- | --- |
| ![Front of the fully routed LED-ring board with filled ground copper](docs/images/routed-front.png) | ![Mirrored rear of the routed board with battery holder and ground fill](docs/images/routed-back.png) |

**Verified routing status (2026-10-04, KiCad 10.0.6): 393 track segments,
36 vias, 0 DRC violations, 0 isolated islands and 0 unconnected items.** All 31
ordinary nets route; GND connectivity is independently verified after native
copper refill. The full locked-dependency build passed both locally and in
[GitHub Actions](https://github.com/andenore/CopperLedRing/actions/runs/37163778171).
The images are from that successful GitHub artifact. No hand-routed tracks,
clearance waivers or via-in-pad permissions are used.

`build/route.json` reports `routing_complete=true` and
`native_fill_verified=true`, but **`fabrication_ready=false`**. Intent-only GND
zones remain deferred in the explicit-copper graph; only the native filled-board
check closes them. Routing completion is not assembly or manufacturing signoff.

The source snapshot's SHA-256 is
`bab5a4c369915ac9b5b6b4e705d3d7c65bd103669b21c0a07d288e61452c0024`
(`board.copper`). Checked-in images are snapshots; regenerate them when the
source/placement changes. The source build, not these images, remains authoritative.

`board.copper` is the authoritative circuit and mechanical intent, including
the circular outline, fixed positions/rotations, front/rear ground pours and
0.15 mm minimum track/clearance rules. There is no Python placement builder,
compiler source, test suite, or manually checked-out component library here.

## Build from a fresh checkout

Install Git, [uv](https://docs.astral.sh/uv/), GNU Make and KiCad 10
with its standard footprint libraries. The inspected baseline uses KiCad 10.0.6.
The Python/compiler and CopperLib Git revisions are pinned by the committed
`uv.lock`, `copper.mod` and `copper.lock`.

```sh
git clone https://github.com/andenore/CopperLedRing.git
cd CopperLedRing
make pcb render             # quick placed/unrouted inspection build
make                        # complete routing, copper refill, native DRC and renders
```

The first build automatically downloads CopperScript and CopperLib from their
pinned GitHub revisions. **Neither repository needs to be checked out manually.**
Later CopperLib operations are locked/offline; footprint geometry comes from
the installed KiCad libraries. No local dependency replacements are used.

Windows (PowerShell with GNU Make on PATH):

```powershell
make pcb render KICAD_CLI="C:/Program Files/KiCad/10.0/bin/kicad-cli.exe" FOOTPRINT_ROOT="C:/Program Files/KiCad/10.0/share/kicad/footprints"
make KICAD_CLI="C:/Program Files/KiCad/10.0/bin/kicad-cli.exe" FOOTPRINT_ROOT="C:/Program Files/KiCad/10.0/share/kicad/footprints"
```

Targets:

| Target | Purpose |
| --- | --- |
| `make check` | Install locked dependencies, fetch/verify CopperLib, run ERC |
| `make pcb` | Export a placed, unrouted KiCad inspection project |
| `make route` | Run package escapes, detailed routing and native fill verification; profile every run |
| `make render` | Render front/back copper SVGs from the existing PCB |
| `make verify` | Refill/save copper and reject all native violations and opens |
| `make order` | Ordering gate; currently blocked, never produces a release |

Generated KiCad files/local footprint tables, SVGs, routing/DRC reports and
`route.pstats` stay under ignored `build/`. Use `make render` to inspect a
draft left by a failed routing attempt. A nonzero exit is a failed check, not a
successful build. Do not use `make -i` to prepare an order. Routing can take
considerably longer than the inspection build.

For the README preview layer combinations, export from an existing inspection
build using KiCad (on Windows, use the executable path shown above):

```sh
kicad-cli pcb export svg --layers F.Cu,F.Silkscreen,Edge.Cuts --mode-single --fit-page-to-board --exclude-drawing-sheet --check-zones -o build/readme-front.svg build/board.kicad_pcb
kicad-cli pcb export svg --layers B.Cu,B.Fab,B.Silkscreen,Edge.Cuts --mirror --mode-single --fit-page-to-board --exclude-drawing-sheet --check-zones -o build/readme-back.svg build/board.kicad_pcb
```

The committed PNGs are rasterizations of those SVGs on a white background.

## Use this project as a template

Fork/copy the repository, change the module identity in `copper.mod`, then edit
`board.copper` to define your circuit, outline and constraints. Keep build and
verification logic in CopperScript/KiCad; the Makefile should remain simple.
Reusable part/device definitions belong in [CopperLib](https://github.com/andenore/CopperLib)
or another URL-imported library, not inside the compiler or a copied fixture.
Keep full commit pins and regenerate/review locks intentionally when upgrading.

## Order the proof of concept

Once an **order-ready** tagged release has passed routing, independent CAM and
assembly validation, it should contain the Gerber/Excellon bundle, assembly BOM,
component placement (CPL) files, exact JLCPCB selections, inspection reports and
checksums. Those files are the direct-order proof of concept; editing the source
should not be necessary to reproduce that released board.

Until that release exists, the GitHub artifacts are **inspection drafts only**.
Remaining ordering gates:

The [assembly-pinning trial](ASSEMBLY.md) records three exact JLCPCB candidates
and the remaining unresolved selections. It is not an orderable BOM or stock check.

- Preserve the completed routing/native DRC result when qualifying exact parts.
- Qualify the circular outline, copper fill and drill outputs independently.
- Replace illustrative LED/passive definitions with verified orderable parts in
  CopperLib; verify all JLCPCB selections, footprints, rotations and assembly sides.
- Produce and validate the assembly BOM/CPL, including the rear holder and SWD header.
- Supply a reviewed firmware/flash procedure and tag the verified source/toolchain.

Do not assume battery supply or firmware programming is included in PCBA.
This repository currently contains no firmware. The proof-of-concept user must
supply the CR2032 and program the MCU over SWD unless a qualified ordering guide
explicitly includes those services. The primary cell is **not rechargeable**:
SWD VREF is sense-only; never inject debugger power with the cell installed.
Firmware must keep the radio, NFC, HFXO and DC/DC disabled as appropriate and use
the internal clocks/LDO configuration. GPIO output LOW illuminates an LED.

## GitHub artifacts

Every push to `main`, pull request, manual run and `v*` tag runs the full `make`
workflow: routing, native KiCad DRC/connectivity checks, and layer rendering.
Routing is not an optional manual/tag-only step. Any routing failure, DRC
violation or open connection fails the job. Failed runs retain native diagnostics
and available layer previews as inspection artifacts, never as successful boards.
There is no automatic manufacturing release while the ordering gates are open.

MIT license. Experimental hardware; review independently before manufacture.
