# Assembly-pinning trial

The committed `assembly.lock` is a **partial, unreviewed prototype**, not an
orderable BOM. It binds the compiled circuit and pinned CopperLib contents to
explicit board-side procurement choices without changing connectivity.

Public catalogue identity checked on 2026-10-03:

| Reference | Full manufacturer MPN | JLCPCB code |
| --- | --- | --- |
| U1 | Nordic Semiconductor NRF52832-QFAA-R | [C77540](https://jlcpcb.com/partdetail/NordicSemicon-NRF52832_QFAAR/C77540) |
| BT1 | Keystone Electronics 3034 | [C5199422](https://jlcpcb.com/partdetail/Keystone-3034/C5199422) |
| J_SWD | Samtec FTSH-105-01-L-DV-007-K | [C5296739](https://jlcpcb.com/partdetail/Samtec-FTSH_105_01_L_DV_007K/C5296739) |

Only 3 of 34 populated components have an exact candidate selection. The other
31 are twelve LEDs, thirteen resistors and six capacitors. Their ratings,
polarity/pin mapping, operating characteristics and exact orderable selections
must be reviewed before replacing illustrative library parts in CopperLib.
The three candidates also remain `reviewed=false`: catalogue identity alone
does not qualify footprint dimensions, assembly rotation, stock or the order.

## Prototype commands

These commands require the new CopperScript `assembly` feature. The project's
existing released Git pin has **not** been upgraded by this local experiment;
`uv run --locked` at that pin does not yet expose these commands. Update the
compiler pin/`uv.lock` to a published feature revision before using them in the
normal template build. No sibling CopperLib checkout is needed.

```sh
copper assembly check board.copper --locked --offline --lock assembly.lock --report build/assembly.json
copper assembly bom board.copper --locked --offline --lock assembly.lock -o build/bom.csv
```

The first command must currently fail with unresolved/unreviewed selections;
the second must refuse export. This is a successful rejection test, not a
successful manufacturing build. Existing routing and ordering gates are unchanged.

## API status

No authenticated API request or live stock check has been performed. JLCPCB's
[official API access application](https://jlcpcb.com/help/article/jlcpcb-online-api-available-now)
requires account approval. Its linked documentation could not be retrieved in
this experiment, and no JLC-specific credential environment variables were
present. Do not guess private endpoints or commit keys. Catalogue pages are
evidence of identity/listing, not stock availability or a reservation.

For real ordering, complete exact selections, validate library/footprint mappings,
check PCBA availability for the board quantity, and inspect JLCPCB's uploaded
BOM matching result. The cell itself is separate from the holder.
