package require Tk

if {[catch {ttk::style theme use clam}]} {
    # Fall back to the default ttk theme if clam is unavailable.
}

ttk::style configure TButton -background "#2f78c7" -foreground "#eff6ff" -padding "8 6"
ttk::style map TButton -background [list pressed "#3d8df0" active "#3d8df0"] -foreground [list pressed "#ffffff" active "#ffffff"]

lappend auto_path ./lib
package require fanout::model
package require fanout::render

source ui/canvasHelpers.tcl
source ui/window.tcl
source ui/status.tcl
source ui/bindings.tcl
source units/conversions.tcl
source controller/state.tcl
source controller/events.tcl
source controller/orchestrator.tcl
source controller/bgaController.tcl
source view/view.tcl
source lib/structures/structures.tcl

set ::render::canvas [ui::window::createMainWindow]
set ::render::unitConversion 1
controller::setMode edit
set ::model::bga [model::bga::createBGA]
set ::model::clineSeg [model::clineSeg::createSeg]



