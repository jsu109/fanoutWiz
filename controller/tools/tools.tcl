namespace eval controller::tools {}

source [file join [file dirname [info script]] measure.tcl]
package provide controller::tools 1.0


set ::controller::tool(select)  {label "SELECT MODE"  next "measure" hint "Select and inspect objects"}
set ::controller::tool(measure) {label "MEASURE MODE" next "select"  hint "Click two features to measure distance"}

proc controller::tools::setActiveTool {{tool select}} {
    set ::controller::activeTool $tool
    ui::status::set "Active Tool: $tool"
    ui::window::setActiveText modeLabel "Active Tool: $tool"
}
proc controller::tools::getTool {} {

    switch $::controller::activeTool {

        select {
            return {controller::selection::featureSelect}
        }
        measure {
            return {controller::selection::measureSelect}
        }
    }
}


proc controller::tools::getNextTool {} {
    set current $::controller::activeTool

    if {![info exists ::controller::tool($current)]} {
        return select
    }

    return [dict get $::controller::tool($current) next]
}

proc controller::tools::toggleTool {} {
    set next [controller::tools::getNextTool]
    controller::tools::setActiveTool $next
}