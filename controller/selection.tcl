namespace eval controller::selection {
    variable selectionQueue {}
}
proc controller::selection::handleSelection {canvas featureId } {
    variable selectionQueue
    lappend selectionQueue $featureId
    set selectionMode [controller::tools::getTool] 
    
    $selectionMode $canvas $featureId
}
proc controller::selection::featureSelected {canvas featureId} {
    if {$featureId ne ""} {
        render::highlight::highlightFeature $canvas $featureId "green" 
        ui::status::set "Selected feature: $featureId"
    } else {
        ui::status::set "No selection"
    }
}
proc controller::selection::measureSelect {canvas featureId} {
    variable selectionQueue
    if {[llength $selectionQueue] > 2} {
        set old [lindex $selectionQueue 0]
        render::highlight::clearHighlight $canvas $old

        set selectionQueue [lrange $selectionQueue end-1 end]
    }

    render::highlight::highlightFeature $canvas $featureId 
    puts "measureSelect: added $featureId to measurement queue: $selectionQueue"
    if {[llength $selectionQueue] == 2} {
        controller::tools::measure::measureBetween \
            $canvas \
            [lindex $selectionQueue 0] \
            [lindex $selectionQueue 1]
    }
}   

proc controller::selection::clearSelection {canvas} {
    variable selectionQueue
    # Clear highlight on the currently selected feature before resetting state.
    if {[llength $selectionQueue] > 0} {
        foreach featureId $selectionQueue {
            render::highlight::clearHighlight $canvas $featureId
        }
    }
    set selectionQueue {}
    ui::status::set "No selection"
    # deselect all
}

