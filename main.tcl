package require Tk

source model/bga.tcl
source model/clineSeg.tcl
source model/fanout.tcl
source model/fanoutCompiler.tcl
source model/topology.tcl
source render/pads.tcl
source render/clineSeg.tcl
source render/fanout.tcl
source ui/window.tcl
source ui/status.tcl
source ui/bindings.tcl
source controller/bgaController.tcl
source view/view.tcl
source strategy/fanout.tcl
source units/conversions.tcl
set ::render::canvas [ui::window::createMainWindow]
set ::render::unitConversion 1
controller::setMode edit
set ::model::bga [model::bga::createBGA]
set ::model::clineSeg [model::clineSeg::createSeg]



