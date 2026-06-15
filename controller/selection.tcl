namespace eval controller::selection {
    variable selectionQueue {}
}
proc controller::selection::handleSelection {canvas featureId } {
    variable selectionQueue
    foreach id $selectionQueue {
        if {$id eq $featureId} {
            puts "$featureId is already Selected"
            return 
        }
    }
    lappend selectionQueue $featureId
    set selectionMode [controller::tools::getTool] 
    
    $selectionMode $canvas
    puts $selectionMode
}
proc controller::selection::featureSelect {canvas } {
    variable selectionQueue
    # clear hightlighting first 
    
    render::highlight::clearAllHighlights $canvas
    # currently single selection -> removed all features but the most recently appended feature
    set selectionQueue [lrange $selectionQueue end end]
    set featureId [lindex $selectionQueue end]
    if {$featureId ne ""} {
        render::highlight::highlightFeature $canvas $featureId "green" 
        ui::status::set "Selected feature: $featureId"
    } else {
        ui::status::set "No selection"
    }
}
proc controller::selection::measureSelect {canvas  } {
    variable selectionQueue
    set newfeatureId [lindex $selectionQueue end]
    if {[llength $selectionQueue] > 2} {
        
        set old [lindex $selectionQueue 0]
        render::highlight::clearHighlight $canvas $old

        set selectionQueue [lrange $selectionQueue end-1 end]
    }

    render::highlight::highlightFeature $canvas $newfeatureId
    puts "measureSelect: added $newfeatureId to measurement queue: $selectionQueue"
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

