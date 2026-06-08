namespace eval controller::tools {}

source [file join [file dirname [info script]] measure.tcl]
package provide controller::tools 1.0


set ::controller::tool(select)  {label "SELECT MODE"  next "measure" hint "Select and inspect objects"}
set ::controller::tool(measure) {label "MEASURE MODE" next "select"  hint "Click two features to measure distance"}

proc controller::tools::setActiveTool {{tool select}} {
    set ::controller::activeTool $tool
    ui::status::set "Active Tool: $tool"
}
proc controller::tools::dispatch {canvas featureId} {

    switch $::controller::activeTool {

        select {
            controller::selection::handleSelect $canvas $featureId
        }

        measure {
            controller::tools::measure::onFeatureSelected $featureId
        }
    }
}