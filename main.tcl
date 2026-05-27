package require Tk

lappend auto_path ./lib
package require fanout::model
package require fanout::render

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



