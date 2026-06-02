$author-display-name
06/02/2026
Recommended Design Rules and Strategies
for BGA Devices User Guide (UG1099)
$author-display-name

Introduction
General BGA and PCB Layout Overview
Layer Count Estimation and Optimization
Layer Count Optimization
Fabrication Technologies
Maximum Board Thickness and Aspect Ratio
Recommended BGA Ball Pad, Via, and Trace
Dimensions for 1.0 mm, 0.92 mm, 0.8 mm, and 0.5 mm
Devices
Power Delivery to the FPGA
Sample Breakouts for 1.0 mm, 0.92, and 0.8mm Pitch
Devices
Sample Breakout for 0.5 mm Pitch Devices

Recommended Design Rules and
Strategies for BGA Devices User Guide
(UG1099)
Introduction
AMD Versal™ architecture, AMD UltraScale™ architecture, 7 series, AMD Virtex™
6, and AMD Spartan™ 6 devices come in a variety of packages that are designed
for maximum performance and maximum flexibility. Four pitch sizes are available
for these packages: 1.0 mm, 0.92 mm, 0.8 mm, and 0.5 mm. In general, as the
pitch size decreases, the challenges for PCB routing increase as there is less room
to route traces and vias between package balls. This guide illustrates various
methods for successful design regardless of pitch size.
✎✎ NNoottee:: Throughout this guide, various specifications and estimates are given
regarding PCB pricing, costs, and technology. As PCB manufacturing technology
is constantly advancing, it is highly advised to consult with your PCB manufacturer
to fully understand their capabilities regarding the information presented here.
General BGA and PCB Layout Overview
The primary factor that determines the intricacy of BGA routing is the pitch size. In
addition, factors such as the size of the BGA array, type of solder masks used, and
layer count requirements also play crucial factors.
Pitch size is defined as the distance between consecutive balls on a BGA package,
measured from center-to-center, as shown in the following diagram.

FFiigguurree:: DDeeffiinniittiioonn ooff PPiittcchh SSiizzee
BGA Landing Pads
AMD recommends using non-solder mask-defined (NSMD) copper BGA landing
pads for optimum board design. NSMD pads are pads that are not covered by any
solder mask, as opposed to Solder Mask Defined (SMD) pads in which a small
amount of solder mask covers the pad landing. The following figure illustrates the
difference between NSMD and SMD pads.

FFiigguurree:: NNSSMMDD aanndd SSMMDD PPaaddss
Layer Count Estimation and Optimization
Layer Count Estimation
A quick way to estimate the number of signal routing layers required to fully break
out signal pins from the FPGA would be to use the following equation:
FFiigguurree:: LLaayyeerrss
For AMD FPGAs, MPSoCs/RFSoCs, and adaptive SoCs, the quantity of signals is
approximately 60% of the number of BGA balls. The other 40% are power and
ground signals that are most often routed directly down to their own dedicated
planes by vias. The equation assumes full I/O utilization. If fewer I/Os are used, the
number of signals to route goes down accordingly.
Routing channels are the number of available routing paths out of the BGA area
(the number of BGA pins on one side minus one, times four sides). The following
figure shows a 5x5 grid with sixteen total routing channels (four routing channels
per side times four sides).

FFiigguurree:: DDeeffiinniittiioonn ooff RRoouuttiinngg CChhaannnneell ((1166 TToottaall RRoouuttiinngg CChhaannnneellss SShhoowwnn))
Routes per channel is either one or two, depending on whether one or two signals
are routed between BGA pads. The approximate number of signal layers required
to fully route out an AMD FPGA or adaptive SoC are shown in the following table.
TTaabbllee:: AApppprrooxxiimmaattee SSiiggnnaall LLaayyeerrss ppeerr nnoo.. ooff PPaacckkaaggee PPiinnss
BBGGAA PPiinnss BBaallll PPiittcchh RRoouuttiinngg EEssttiimmaatteedd SSiiggnnaall LLaayyeerrss
((mmmm)) CChhaannnneellss RReeqquuiirreedd wwiitthh AAllll AAvvaaiillaabbllee II//
OOss RRoouutteedd
OOnnee TTrraaccee TTwwoo TTrraacceess
PPeerr RRoouuttiinngg PPeerr RRoouuttiinngg
CChhaannnneell CChhaannnneell

BBGGAA  PPiinnss BBaallll  PPiittcchh RRoouuttiinngg EEssttiimmaatteedd  SSiiggnnaall  LLaayyeerrss
((mmmm)) CChhaannnneellss RReeqquuiirreedd  wwiitthh  AAllll  AAvvaaiillaabbllee  II//
OOss  RRoouutteedd
|      |         | OOnnee  TTrraaccee     | TTwwoo  TTrraacceess   |     |
| ---- | ------- | ---------------------- | ---------------------- | --- |
|      |         | PPeerr  RRoouuttiinngg | PPeerr  RRoouuttiinngg |     |
|      |         | CChhaannnneell         | CChhaannnneell         |     |
| 196  | 0.5     | 52                     | 2                      | 1   |
| 196  | 1.0     | 52                     | 2                      | 1   |
| 225  | 0.8     | 56                     | 2                      | 1   |
| 236  | 0.5     | 56                     | 3                      | 1   |
| 238  | 0.5     | 56                     | 3                      | 1   |
| 256  | 1.0     | 60                     | 3                      | 1   |
| 324  | 0.8     | 68                     | 3                      | 1   |
| 400  | 0.8     | 76                     | 3                      | 2   |
| 484  | 0.8/1.0 | 84                     | 3                      | 2   |
| 485  | 0.8     | 84                     | 3                      | 2   |
| 494  | 0.5     | 84                     | 4                      | 2   |
| 530  | 0.5     | 88                     | 4                      | 2   |
| 625  | 0.8     | 96                     | 4                      | 2   |
| 676  | 1.0     | 100                    | 4                      | 2   |
| 784  | 0.8/1.0 | 108                    | 4                      | 2   |
| 900  | 1.0     | 116                    | 5                      | 2   |
| 1024 | 0.92    | 124                    | 5                      | 2   |
| 1154 | 1.0     | 132                    | 5                      | 3   |
| 1155 | 1.0     | 132                    | 5                      | 3   |

BBGGAA  PPiinnss BBaallll  PPiittcchh RRoouuttiinngg EEssttiimmaatteedd  SSiiggnnaall  LLaayyeerrss
((mmmm)) CChhaannnneellss RReeqquuiirreedd  wwiitthh  AAllll  AAvvaaiillaabbllee  II//
OOss  RRoouutteedd
|      |          | OOnnee  TTrraaccee     | TTwwoo  TTrraacceess   |     |
| ---- | -------- | ---------------------- | ---------------------- | --- |
|      |          | PPeerr  RRoouuttiinngg | PPeerr  RRoouuttiinngg |     |
|      |          | CChhaannnneell         | CChhaannnneell         |     |
| 1156 | 1.0      | 132                    | 5                      | 3   |
| 1157 | 1.0      | 132                    | 5                      | 3   |
| 1365 | 0.92     | 144                    | 6                      | 3   |
| 1369 | 0.92     | 144                    | 6                      | 3   |
| 1517 | 1.0      | 152                    | 6                      | 3   |
| 1596 | 0.92     | 156                    | 6                      | 3   |
| 1759 | 1.0      | 164                    | 6                      | 3   |
| 1760 | 0.92/1.0 | 164                    | 6                      | 3   |
| 1761 | 1.0      | 164                    | 6                      | 3   |
| 1923 | 1.0      | 172                    | 7                      | 3   |
| 1924 | 1.0      | 172                    | 7                      | 3   |
| 1925 | 1.0      | 172                    | 7                      | 3   |
| 1926 | 1.0      | 172                    | 7                      | 3   |
| 1927 | 1.0      | 172                    | 7                      | 3   |
| 1928 | 1.0      | 172                    | 7                      | 3   |
| 1930 | 1.0      | 172                    | 7                      | 3   |
| 2104 | 1.0      | 180                    | 7                      | 4   |
| 2197 | 0.92     | 184                    | 7                      | 4   |
| 2377 | 1.0      | 188                    | 8                      | 4   |

BBGGAA  PPiinnss BBaallll  PPiittcchh RRoouuttiinngg EEssttiimmaatteedd  SSiiggnnaall  LLaayyeerrss
((mmmm)) CChhaannnneellss RReeqquuiirreedd  wwiitthh  AAllll  AAvvaaiillaabbllee  II//
OOss  RRoouutteedd
|      |      | OOnnee  TTrraaccee     | TTwwoo  TTrraacceess          |     |
| ---- | ---- | ---------------------- | ----------------------------- | --- |
|      |      | PPeerr  RRoouuttiinngg | PPeerr  RRoouuttiinngg        |     |
|      |      |                        | CChhaannnneell CChhaannnneell |     |
| 2577 | 1.0  | 200                    | 8                             | 4   |
| 2785 | 0.92 | 208                    | 8                             | 4   |
| 2892 | 1.0  | 212                    | 8                             | 4   |
| 3340 | 0.92 | 228                    | 9                             | 4   |
| 3824 | 1.0  | 244                    | 9                             | 5   |
| 4072 | 1.0  | 252                    | 10                            | 5   |
| 5601 | 0.92 | 296                    | 11                            | 6   |
Layer Count Optimization
Versal architecture, UltraScale architecture, 7 series, Virtex 6, and Spartan 6 device
packages have full matrices of solder balls. The true number of layers required for
effective routing of these packages is dictated by a variety of factors, including:
•
BGA size (quantity of pins)
•
Pad size, pad pitch, and trace width
•
Fixed pinouts
•
Back Drilling
•
Fabrication Technologies
BGA Size
The quantity of pins in a BGA indicates the number of signals to route. Because of
physical space constraints, the quantity of signals required to route is proportional
to the amount of signal layers required.

Pad Size, Pad Pitch, and Trace Width
The pad size and pitch determine the available space between adjacent balls for
signal escape. Based on the chosen trace width, one or two signals can be routed
between adjacent pads. If one signal escapes between adjacent pads, then one
signal row can be routed on a single metal layer. The exception to this is the
outermost row, which allows two routes per layer.
To facilitate routing in the ball grid area, necking down the trace width in the critical
space between the BGA pads/vias (the breakout area) is allowable. This then
allows for two signal rows to be routed on a single metal layer (or three if routing the
outermost row). The traces can then be widened after they escape the breakout
area. Changes in width over very short distances can cause small impedance
changes. Validate these issues with the board vendor and signal integrity engineers
responsible for the design.
Fixed Pinouts
AMD FPGA and adaptive SoC pinouts are designed with maximum flexibility in
mind. However, certain FPGA/adaptive SoC signals, such as JTAG, transceiver
inputs and outputs, and memory controller signals (among others) have fixed
locations, which means routing of these signals is limited compared to other signals
that can be swapped as needed. Fixed locations lead to layout trade-offs that can
have an impact on the number of required signal layers.
Back Drilling
Back drilling is the technique is which unused via stubs have their metal drilled
away to remove the potential for the stubs to cause reflections which can cause
signal integrity problems. Typically, back drilling can prevent the ability to route
more than one signal in-between pads and vias due to manufacturability concerns.
Always consult with the PCB manufacturer regarding the ability to back drill before
beginning and layout activity.
Fabrication Technologies
Several advanced fabrication technologies can be used to reduce the number of

layers required to route a design.
Blind Vias
Unlike through-hole vias, which extend through the entire thickness of the PCB from
the top layer all the way to the bottom layer, blind vias connect only an outer layer
(either the top or bottom) to one or more inner signal layers without passing
completely through the board. This selective connectivity enables designers to free
up valuable routing space on the outer layers by avoiding the need to route signals
through the entire board thickness. As a result, blind vias help improve signal
density and reduce layer count, which can lead to smaller, more compact PCB
designs.
Buried Vias
Buried vias are vias that connect only inner layers within the PCB stack-up and do
not extend to the top or bottom surface layers. Because they are completely
encapsulated inside the PCB, buried vias are not visible or accessible from the
outside. Their primary purpose is to enable high-density interconnections between
internal layers without occupying valuable surface real estate or interfering with
surface-mounted components. Buried vias are particularly useful in multi-layer
boards where signal integrity and routing complexity demand precise control of
internal layer connections.
Via-in-Pad
Via-in-pad technology places a via directly within a component pad, such as those
found on BGA packages. This method eliminates the need for “dog-bone” routing,
where a signal trace extends from the pad to a nearby via on the outer layers. By
situating the via right in the pad, the signal can travel directly from the component
pin down to an inner layer, significantly simplifying the routing process under dense
BGAs and other fine-pitch components.
This approach offers several advantages:
•
IImmpprroovveedd RRoouuttiinngg DDeennssiittyy

Via-in-pad frees up surface routing space, allowing easier escape routes for
signals, especially under BGAs where routing channels are extremely limited.
•
EEnnhhaanncceedd SSiiggnnaall IInntteeggrriittyy
Because the signal path transitions directly from the pad to an internal layer, the
length of the top or bottom layer trace is minimized or eliminated, reducing
parasitic inductance and capacitance. This improves impedance control and
overall high-frequency performance.
•
BBeetttteerr TThheerrmmaall PPeerrffoorrmmaannccee
Via-in-pad also helps with heat dissipation from components by providing a
direct thermal path to internal or bottom layers.
However, via-in-pad requires specialized manufacturing processes such as via
filling and plating to ensure flat, reliable pads suitable for soldering components.
The following figure illustrates the mechanical design of a via-in-pad, showing the
via embedded within the pad structure.
FFiigguurree:: VViiaa--IInn--PPaadd SSttrruuccttuurree
Maximum Board Thickness and Aspect Ratio
The maximum board thickness is a function of the minimum drill diameter and
aspect ratio, both of which are provided by the PCB manufacturer. A typical aspect
ratio of 15:1 indicates that the board can be no thicker than fifteen times the drill
diameter. A drill diameter of 10 mils, for example, would lead to a maximum board

thickness of 150 mils. Apart from the CP package, AMD recommends finished drill
diameters to be 10-15 mils, which translates to an actual drill diameter of about
13-18 mils (plating typically reduces the diameter by about 3 mils). A 10 mil drill
would lead to a maximum board thickness of 100 mils for a 10:1 ration, or 150mils
for a 15:1 ratio. Advanced manufacturing technologies can support from 17:1 to
22:1 ratio, but at increased costs.
Recommended BGA Ball Pad, Via, and Trace Dimensions for 1.0
mm, 0.92 mm, 0.8 mm, and 0.5 mm Devices
✎✎ NNoottee:: The figures in this chapter assume that signals are routed from the BGA
ball to a via in a dog-bone configuration where the signal from the BGA routes
diagonally from the pad to a via on the same routing layer. Via-In-Pad (VIP)
technology (see the Via-In-Pad Structure figure in Fabrication Technologies) can
be used to place a via directly on top of a BGA pad so it can travel straight down to
an inner signal layer.
Recommended BGA Ball Pad and Via Dimensions for
1.0 mm, 0.92 mm, 0.8 mm, and 0.5 mm Devices
The definition of dimensions of FPGA/adaptive SoC ball pads and vias for AMD
BGA devices are show in the following figure. The table that follows shows the
actual dimensions based on BGA ball pitch.

FFiigguurree::  BBGGAA  BBaallll  aanndd  VViiaa  DDeeffiinniittiioonn  ooff  DDiimmeennssiioonnss
TTaabbllee::  BBGGAA  BBaallll  aanndd  VViiaa  DDiimmeennssiioonnss
SSoollddeerr  BBaallll 11..00  mmmm 00..9922  mmmm 00..88  mmmm 00..55  mmmm
LLaanndd  PPiittcchh
((ee))
| Solder Mask | 20.9 mil | 20.9 mil | 15.7 mil | 11.0 mil |
| ----------- | -------- | -------- | -------- | -------- |
Opening
| Diameter (L) | 0.53 mm  | 0.53 mm  | 0.40 mm  | 0.28 mm  |
| ------------ | -------- | -------- | -------- | -------- |
| BGA Solder   | 19.7 mil | 20.0 mil |          |          |
|              |          |          | 15.7 mil | 10.2 mil |
Land Pad
Diameter (M)
|     | 0.50 mm | 0.51 mm | 0.40 mm | 0.26 mm |
| --- | ------- | ------- | ------- | ------- |

SSoollddeerr  BBaallll 11..00  mmmm 00..9922  mmmm 00..88  mmmm 00..55  mmmm
LLaanndd  PPiittcchh
((ee))
Via Plating
| 19 mil | 19 mil | 19 mil | 10 mil |
| ------ | ------ | ------ | ------ |
Diameter
(VD)
| 0.48 mm | 0.48 mm | 0.48 mm | 0.254 mm |
| ------- | ------- | ------- | -------- |
Via Finished
| 10 mil | 10 mil | 10 mil | 4 mil |
| ------ | ------ | ------ | ----- |
Hole
Diameter
| 0.25 mm | 0.25 mm | 0.25 mm | 0.10 mm |
| ------- | ------- | ------- | ------- |
(VH)
Distance
| 27.83 mil | 25.61 mil | 22.27 mil | 13.92 mil |
| --------- | --------- | --------- | --------- |
between
BGA Pad
| 0.70 mm | 0.65 mm | 0.56 mm | 0.35 mm |
| ------- | ------- | ------- | ------- |
and Via)
Recommended Trace Routing between Pads and Vias
for 1.0 mm, 0.92 mm, 0.8 mm, and 0.5 mm Devices
The ball pitch and BGA pad/via diameters determine how much space is available
to route traces between pads or vias. Standard PCB processes can allow for as low
as 3.5 mil trace widths with 3.5 mil spacing. Advanced processes can allow for as
low as 2 mil trace widths with 2 mil spacing. Recommended trace routing is shown
in the following figure. The table that follows shows the actual BGA/trace routing
dimensions.

FFiigguurree::  BBGGAA//TTrraaccee  RRoouuttiinngg  DDiimmeennssiioonnss
TTaabbllee::  BBGGAA//TTrraaccee  RRoouuttiinngg  DDiimmeennssiioonnss
SSoollddeerr  BBaallll 3399..3399  mmiill 3366..2222  mmiill 3311..4400  mmiill 1199..77  mmiill
LLaanndd  PPiittcchh
|     | 11..00  mmmm | 00..9922  mmmm | 00..88  mmmm | 00..55  mmmm |
| --- | ------------ | -------------- | ------------ | ------------ |
((ee))
PCB Solder
|     | 19.7 mil | 20.0 mil | 15.7 mil | 10.63 mil |
| --- | -------- | -------- | -------- | --------- |
Land
Diameter (L)
|           | 0.50 mm | 0.51 mm | 0.40 mm | 0.27 mm |
| --------- | ------- | ------- | ------- | ------- |
| Available | 19 mil  | 16 mil  | 15 mil  | 9 mil   |
Routing
|     | 0.33 mm | 0.40 mm | 0.38 mm | 0.23 mm |
| --- | ------- | ------- | ------- | ------- |
Distance (R)
| Pad-to- | 7.5 mil | 6 mil | 5 mil | 1   |
| ------- | ------- | ----- | ----- | --- |
3
Trace/Trace-
to-Trace
Spacing for
| one route | 0.19 mm | 0.15 mm | 0.13 mm | 0.08 mm |
| --------- | ------- | ------- | ------- | ------- |
between
pads (S1)
| Trace | 4   | 4   | 4   | 3   |
| ----- | --- | --- | --- | --- |
thickness for

SSoollddeerr  BBaallll 3399..3399  mmiill 3366..2222  mmiill 3311..4400  mmiill 1199..77  mmiill
LLaanndd  PPiittcchh
| ((ee)) | 11..00  mmmm | 00..9922  mmmm | 00..88  mmmm | 00..55  mmmm |
| ------ | ------------ | -------------- | ------------ | ------------ |
one route
| between | 0.10 mm | 0.10 mm | 0.10 mm | 0.08 mm |
| ------- | ------- | ------- | ------- | ------- |
pads (W1)
| Pad-to- |       |       | 3 mil | N/A |
| ------- | ----- | ----- | ----- | --- |
|         | 4 mil | 3 mil |       |     |
Trace/Trace-
to-Trace
Spacing for
two route
|     | 0.10 mm | 0.08 mm | 0.08 mm |     |
| --- | ------- | ------- | ------- | --- |
between
pads (S2)
| Trace | 3 mil | 3 mil | 3 mil | N/A |
| ----- | ----- | ----- | ----- | --- |
thickness for
two route
|     | 0.08 mm | 0.08 mm | 0.08 mm |     |
| --- | ------- | ------- | ------- | --- |
between
pads (W2)
1. 3 mil pad-to-trace is not supported by all manufacturers.
Recommended Trace Routing between Vias
One or two traces can be routed in-between vias for 1.0 mm, 0.92 mm, and 0.80
mm pitch devices. It is not practical to route traces in-between vias spaced 0.5 mm
apart due to the tight spacing and trace widths required. For those situations, it is
recommended to use Via-in-Pad technology for added pitch between vias.
Recommended via/trace routing is shown in the following figure. The table that
follows shows the actual BGA/trace routing dimensions.

FFiigguurree::  VViiaa//TTrraaccee  RRoouuttiinngg
TTaabbllee::  VViiaa//TTrraaccee  RRoouuttiinngg  DDiimmeennssiioonnss
SSoollddeerr  BBaallll 3399..3399  mmiill 3366..2222  mmiill 3311..4400  mmiill 1199..77  mmiill
LLaanndd  PPiittcchh
|     | 11..00  mmmm | 00..9922  mmmm | 00..88  mmmm | 00..55  mmmm |
| --- | ------------ | -------------- | ------------ | ------------ |
((ee))
| Via Drill | 10 mil | 10 mil | 10 mil | 4 mil |
| --------- | ------ | ------ | ------ | ----- |
Diameter
|     | 0.25 mm | 0.25 mm | 0.25 mm | 0.10 mm |
| --- | ------- | ------- | ------- | ------- |
(VD)
| Available | 29 mil | 26 mil | 21 mil | 15 mil |
| --------- | ------ | ------ | ------ | ------ |
Routing
|     | 0.74 mm | 0.66 mm | 0.53 mm | 0.38 mm |
| --- | ------- | ------- | ------- | ------- |
Distance (R)
| Via-to-Trace/ | 12 mil | 11 mil | 8 mil | 5 mil |
| ------------- | ------ | ------ | ----- | ----- |
Trace-to-
Trace
Spacing for
|     | 0.30 mm | 0.28 mm | 0.20 mm | 0.13 mm |
| --- | ------- | ------- | ------- | ------- |
one route
between
pads (S1)

SSoollddeerr BBaallll 3399..3399 mmiill 3366..2222 mmiill 3311..4400 mmiill 1199..77 mmiill
LLaanndd PPiittcchh
11..00 mmmm 00..9922 mmmm 00..88 mmmm 00..55 mmmm
((ee))
Trace
4 mil 4 mil 4 mil 4 mil
thickness for
one route
between
0.10 mm 0.10 mm 0.10 mm 0.10 mm
pads (W1)
Pad-to- 10 mil 6 mil 5 mil 3 mil 1
Trace/Trace-
to-Trace
Spacing for
two route 0.25 mm 0.15 mm 0.13 mm 0.08 mm
between
pads (S2)
Trace
4 mil 4 mil 3 mil 3 mil
thickness for
two route
between
0.10 mm 0.10 mm 0.08 mm 0.08 mm
pads (W2)
1. 3 mil pad-to-trace is not supported by all manufacturers.
Power Delivery to the FPGA
Power needs must be assessed early in the design phase to assure that there are
enough layers and area to provide sufficient power to the BGA balls that require
power. Because most of the BGA power pins are located in the center of the BGA
area, the path the current travels traverses a myriad of vias in the BGA area. The
space between vias can conservatively carry about 0.05A per mil of trace width (for
0.5 oz copper). The trace width between vias is defined by the pitch of the vias
(usually the same as the pitch of the BGA), the via drill diameter, and drill-to-copper
specification as defined by the fabrication house. The following figure shows how to
calculate the amount of current that can pass through each via channel. Ensure that
the power planes are wide enough and encompassing enough to supply the
needed amperage to the BGA power balls. The following equation can be used to

calculate the current per channel:
FFiigguurree:: PPoowweerr DDeelliivveerryy wwiitthhiinn BBGGAA AArreeaa ((00..55 oozz CCooppppeerr))
The following table shows current per channel values for 0.8 mm and 1.0 mm pitch
devices. Because of the very fine pitch of 0.5 mm devices, it is not possible to route
in-between standard vias. Micro-vias under the BGA pads are recommended for 0.5
mm devices in order to reach the power planes
TTaabbllee:: CCuurrrreenntt PPeerr CChhaannnneell CCaallccuullaattiioonn ffoorr 00..88 mmmm,, 00..9922 mmmm,, aanndd 11..00 mmmm
DDeevviicceess
00..88 mmmm PPiittcchh 00..9922 mmmm PPiittcchh 11..00 mmmm PPiittcchh
Via Pitch 31.40 mil 36.22 mil 39.37 mil
Via Drill Diameter 10 mil 10 mil 10 mil

   00..88  mmmm  PPiittcchh 00..9922  mmmm  PPiittcchh 11..00  mmmm  PPiittcchh
| Drill to Copper | 8 mil | 8 mil | 8 mil |
| --------------- | ----- | ----- | ----- |
Specification 1
| Amps per Unit | 0.05 A | 0.05 A | 0.05 A |
| ------------- | ------ | ------ | ------ |
Trace Width
(ATW), 0.5 oz Cu
| Amps per Unit | 0.075 A | 0.075 A | 0.075 A |
| ------------- | ------- | ------- | ------- |
Trace Width
(ATW), 1.0 oz Cu
| Current per | 0.27 A | 0.51 A | 0.67 A |
| ----------- | ------ | ------ | ------ |
Channel, 0.5 oz
Cu
| Current per | 0.41 A | 0.77 A | 1.00 A |
| ----------- | ------ | ------ | ------ |
Channel, 1.0 oz
Cu
1. Drill-to-Copper of 8 mils is considered standard. Between 6.5 and 8 mil are
considered advanced processes.
Sample Breakouts for 1.0 mm, 0.92, and 0.8mm Pitch Devices
The following figures show two example layouts showing the BGA routing breakout
areas of a representative 1.0 mm/0.92 mm/0.80 mm pitch AMD device.
Sample Breakout with One Route between BGA Balls
and Vias

FFiigguurree:: TToopp LLaayyeerr BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, OOnnee RRoouuttee bbeettwweeeenn
BBGGAA BBaallllss

FFiigguurree:: IInnnneerr SSiiggnnaall LLaayyeerr OOnnee BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, OOnnee
RRoouuttee bbeettwweeeenn VViiaass

FFiigguurree:: IInnnneerr SSiiggnnaall LLaayyeerr TTwwoo BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, OOnnee
RRoouuttee bbeettwweeeenn VViiaass

FFiigguurree:: IInnnneerr SSiiggnnaall LLaayyeerr TThhrreeee BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, OOnnee
RRoouuttee bbeettwweeeenn VViiaass

FFiigguurree:: IInnnneerr SSiiggnnaall LLaayyeerr FFiivvee BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, OOnnee
RRoouuttee bbeettwweeeenn VViiaass
Sample Breakout with Two Routes between BGA Balls
and Vias

FFiigguurree:: TToopp LLaayyeerr BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, TTwwoo RRoouutteess
bbeettwweeeenn BBGGAA BBaallllss

FFiigguurree:: IInnnneerr SSiiggnnaall LLaayyeerr OOnnee BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, TTwwoo
RRoouutteess bbeettwweeeenn VViiaass

FFiigguurree:: IInnnneerr SSiiggnnaall LLaayyeerr TTwwoo BBrreeaakkoouutt ((11..00 mmmm//00..9922 mmmm//00..88 mmmm)),, TTwwoo
RRoouutteess bbeettwweeeenn VViiaass
Sample Breakout for 0.5 mm Pitch Devices
The following figures show an example layout showing the BGA routing breakout
areas of a 0.5 mm pitch AMD device. The footprint is for a UBVA530 “InFO” device.

FFiigguurree:: TToopp LLaayyeerr BBrreeaakkoouutt ((00..55 mmmm)),, OOnnee RRoouuttee bbeettwweeeenn BBGGAA BBaallllss

FFiigguurree:: FFiirrsstt IInnnneerr SSiiggnnaall BBrreeaakkoouutt ((00..55 mmmm))

FFiigguurree:: SSeeccoonndd IInnnneerr SSiiggnnaall BBrreeaakkoouutt ((00..55 mmmm))