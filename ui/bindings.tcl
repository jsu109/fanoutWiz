namespace eval ui::bindings {}

namespace eval ui::bindings {}

proc ui::bindings::attachPadSelection {canvas} {

    # single unified click handler (important)
    $canvas bind pad <Button-1> [list ui::bindings::onCanvasClick $canvas]
    $canvas bind seg <Button-1> [list ui::bindings::onCanvasClick $canvas]
    $canvas bind via <Button-1> [list ui::bindings::onCanvasClick $canvas]

    # background click
    $canvas bind background <Button-1> [list ui::bindings::onBackgroundClick $canvas]
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
    render::highlight::highlightFeature $canvas $featureId green
    ui::status::set "Selected: $featureId"
}

# not currently working, need to investigate further
proc ui::bindings::onBackgroundClick {canvas} {

    set item [$canvas find withtag current]

    # canvas background is usually item 1
    if {$item eq 1} {
        render::selection::clear $canvas
        ui::status::set "No selection"
    }
}