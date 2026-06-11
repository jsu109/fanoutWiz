namespace eval ui::bindings {}


proc ui::bindings::attachPadSelection {canvas} {

    # single unified click handler (important)
    $canvas bind pad <Button-1> [list ui::bindings::onCanvasClick $canvas]
    $canvas bind seg <Button-1> [list ui::bindings::onCanvasClick $canvas]
    $canvas bind via <Button-1> [list ui::bindings::onCanvasClick $canvas]
    bind $canvas <Button-1> [list ui::bindings::onCanvasBackgroundClick $canvas %x %y]
}

proc ui::bindings::onCanvasBackgroundClick {canvas x y} {
    set item [$canvas find withtag current]
    if {[llength $item] == 0} {
        controller::selection::clearSelection $canvas
    }
    

}

proc ui::bindings::onCanvasClick {canvas} {

    set item [$canvas find withtag current]
    set tags [$canvas gettags $item]
    
    # extract featureId from tags
    set featureId ""

    foreach t $tags {
        if {[string match feature:* $t]} {
            set featureId [string range $t 8 end]
            break
        }
    }

    if {$featureId eq ""} {
        puts "WARN: no feature tag found"
        return
    }

    set featureIndex [dict get $::controller::lastFrame featureIndex]
    
    if {![dict exists $featureIndex $featureId]} {
        puts "WARN: feature not in index: $featureId"
        return
    }

    set feature [dict get $featureIndex $featureId]
    controller::selection::handleSelection $canvas $featureId
    
}
