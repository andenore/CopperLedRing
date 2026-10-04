# Exact assembly selections

`assembly.lock` binds all **34 populated components** to nine exact manufacturer
MPNs and JLCPCB ordering codes. Electrical values, pin mappings, footprints and
assembly sides were reviewed against manufacturer documents/catalogue identities
on 2026-10-04. `reviewed=true` records this component-selection review, not
supplier stock, factory approval, independent CAM qualification or a tested unit.

| References | Full manufacturer MPN | JLCPCB |
| --- | --- | --- |
| U1 | Nordic Semiconductor NRF52832-QFAA-R | [C77540](https://jlcpcb.com/partdetail/C77540) |
| BT1 | Keystone Electronics 3034 | [C5199422](https://jlcpcb.com/partdetail/C5199422) |
| J_SWD | Samtec FTSH-105-01-L-DV-007-K | [C5296739](https://jlcpcb.com/partdetail/C5296739) |
| LED1–LED12 | Hubei KENTO Elec KT-0603R | [C2286](https://jlcpcb.com/partdetail/C2286) |
| R_LED1–R_LED12, R_RESET | UNI-ROYAL 0603WAF1002T5E, 10 kohm 1% | [C25804](https://jlcpcb.com/partdetail/C25804) |
| C_DEC1, C_VDD1, C_VDD2 | Samsung CL05B104KO5NNNC, 100 nF 16 V X7R | [C1525](https://jlcpcb.com/partdetail/C1525) |
| C_DEC3 | Fenghua 0402CG101J500NT, 100 pF 50 V C0G | [C1546](https://jlcpcb.com/partdetail/C1546) |
| C_DEC4 | Samsung CL10A105KB8NNNC, 1 uF 50 V X5R | [C15849](https://jlcpcb.com/partdetail/C15849) |
| C_BULK | Samsung CL10A475KO8NNNC, 4.7 uF 16 V X5R | [C19666](https://jlcpcb.com/partdetail/C19666) |

## Mapping and footprint review

- MCU: existing CopperLib QFAA pin/bond map and centred 6x6 mm QFN48 footprint,
  grounded exposed pad and Nordic's LDO support circuit. No external clocks or RF.
- Holder: Keystone M65 page 9 / figure 1, centred KiCad 3034 geometry. Pad 1's
  positive retainer tabs are permanently common; pad 2 is the negative PCB contact.
  Fit the holder on the rear. The CR2032 cell is **not** an assembled BOM item.
- SWD: existing CopperLib centred Samtec recommended SMT footprint, 1.27 mm
  pitch, keyed position 7 absent. Pin 1=VREF; VREF must not inject power.
- LED: manufacturer-authored C2286 attachment, revision A.0, 2018-12-06,
  PDF page 2 package/polarity and page 3 ratings. **A=1/K=2**, not generic KiCad
  K=1/A=2. CopperLib supplies the package-owned `KENTO:KENTO_KT0603R`, preserving cathode-left
  nominal IPC 0603 lands with corrected manufacturer terminal numbering.
- Resistor: UNI-ROYAL V.3, 2019-02-12 ordering code/package/rating tables;
  10 kohm, 1%, 0.1 W, 75 V and centred 0603 lands. Board dissipation is well below
  the part rating at the declared 3 V supply.
- Capacitors: Samsung exact Component Center size/characteristic tables and
  Fenghua general MLCC/1005 dimensions plus exact C1546 selection. All are
  nonpolarized; the voltage ratings exceed the 3 V battery supply. Nominal
  capacitance/tolerance and dielectric are explicit in the table above.

Reusable exact definitions, concise evidence and hashes live in
[CopperLib's canonical reusable part packages](https://github.com/andenore/CopperLib/tree/main/packages/parts),
not this project or the compiler. Manufacturer-authored PDFs were retrieved from
official catalogue download links and retained only in ignored library cache.
The KENTO attachment cover describes “0603-0.6 red”, with the commercial part
identity established by its C2286 catalogue attachment. Neither low-current LED
brightness nor battery life has been measured; the catalogue brightness test is
at 20 mA, whereas this board deliberately uses low-current 10 kohm channels.

## Build and ordering checks

```sh
make assembly       # check exact selections and create build/bom.csv
make order          # route, fill, native DRC, BOM, CPL, Gerbers, drills and ZIPs
```

For JLCPCB upload `build/manufacturing/gerbers-drill.zip`, `bom.csv` and `cpl.csv`.
The CPL uses native millimetres, a common unmirrored XY origin, positive CCW
rotation and Top/Bottom sides. Negative Y coordinates are KiCad's native Y-up
export convention, not an accidentally mirrored board. All footprints used
here have centred placement origins. **Verify the supplier's assembled preview**:
LED cathode, MCU pin 1, SWD pin 1 and the rear holder polarity/orientation.
KiCad and supplier zero-angle conventions can differ; no guessed correction is
applied automatically. See [JLC's KiCad export guidance](https://jlcpcb.com/help/article/how-to-generate-the-bom-and-centroid-file-from-kicad).

No authenticated API/live stock reservation has been performed. Check availability
for the actual quantity, BOM matching and assembly eligibility in the order UI.
Do not silently substitute a listed part. Double-sided assembly is required.
The delivered target is assembled **but unprogrammed** hardware; firmware and
flashing are outside this build. Supply the CR2032 separately.
