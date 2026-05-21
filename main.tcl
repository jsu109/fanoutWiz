package require Tk

source model/bga.tcl
source render/pads.tcl
source ui/window.tcl
source ui/status.tcl
source ui/bindings.tcl
source controller/bgaController.tcl

set ::render::canvas [ui::window::createMainWindow]

controller::setMode edit
set ::model::bga [model::bga::createBGA]
after 0 controller::build


