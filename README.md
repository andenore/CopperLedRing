# CopperLedRing

**A minimal [CopperScript](https://github.com/andenore/CopperScript) example
project and reusable board-project template.** It is also intended to be a
direct-order hardware proof of concept: take a qualified release's manufacturing
and assembly files, order the board, and try the design without writing your own
circuit first.

**Current ordering status: DRAFT — no order-ready release exists yet.**
The source and build are usable as a template now, but generated drafts must not
be submitted as an assembled-board order. The current circuit has illustrative
LED/passive selections, routing is not certified complete, and CopperScript's
independent circular-outline CAM release gate is still closed. `make order`
fails closed; it never labels an inspection artifact as production-ready.

## The board

A 50 mm circular, two-layer board with an nRF52832 QFAA controlling twelve
active-low red LEDs, a rear Keystone 3034 CR2032 holder, a 10-pin SMD Cortex-M
SWD header, and bypass/LDO-support capacitors. This is an LED controller:
**Bluetooth is not fitted**, and there is no antenna or external crystal.

`board.copper` is the authoritative circuit and mechanical intent, including
the circular outline, fixed positions/rotations, rear ground pour and
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
make                        # attempt complete routing, render and native DRC
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
| `make route` | Attempt package escapes and detailed routing; profile every run |
| `make render` | Render front/back copper SVGs from the existing PCB |
| `make verify` | Refill/save copper and reject all native violations and opens |
| `make order` | Ordering gate; currently blocked, never produces a release |

Generated KiCad files/local footprint tables, SVGs, routing/DRC reports and
`route.pstats` stay under ignored `build/`. Use `make render` to inspect a
draft left by a failed routing attempt. A nonzero exit is a failed check, not a
successful build. Do not use `make -i` to prepare an order. Routing can take
considerably longer than the inspection build.

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

- Close every connection and pass both CopperScript and native KiCad checks.
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

Pushes and pull requests build the quick inspection project and upload its
KiCad files, layer previews and reports. Manual runs and `v*` tags additionally
attempt full routing. Failed runs retain diagnostics as inspection artifacts.
There is no automatic manufacturing release while the ordering gates are open.

MIT license. Experimental hardware; review independently before manufacture.
