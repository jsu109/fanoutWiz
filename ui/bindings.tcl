namespace eval ui::bindings {}

proc ui::bindings::attachPadSelection {canvas} {

    $canvas bind pad <Button-1> [list ui::bindings::onPadClick $canvas]
    $canvas bind background <Button-1> [list ui::bindings::onCanvasClick $canvas]
}

proc ui::bindings::onPadClick {canvas} {

    set item [$canvas find withtag current]
    set tags [$canvas gettags $item]

    set padName ""
    foreach t $tags {
        if {$t ne "pad"} {
            set padName $t
            break
        }
    }

    ui::status::set "Selected pad: $padName"

    render::pads::highlightPad $canvas $padName
}
proc ui::bindings::onCanvasClick {canvas} {

    set item [$canvas find withtag current]
    if {$item eq 1} {
        render::pads::clearSelection $canvas
        ui::status::set "No selection"
    }
}