source model/bga.tcl
source render/pads.tcl
source ui/window.tcl

set canvas [createMainWindow]

set bgaDef [createBGA]
set pads [generateBGAPads $bgaDef]

drawPads $canvas $pads $bgaDef