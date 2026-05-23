# drawPads
# drawPadLabels
# highlightPad

namespace eval render::pads {}

proc render::pads::drawPads {canvas pads bgaDef} {

    set radius [dict get $bgaDef padRadius]

    dict for {padName padData} $pads {
        
        set sx [expr {[dict get $padData x] * $::view::scale * $::render::unitConversion + $::view::offsetX}]
        set sy [expr {[dict get $padData y] * $::view::scale * $::render::unitConversion + $::view::offsetY}]
        set sr [expr {$radius * $::view::scale * $::render::unitConversion}]
        set padType [dict get $padData type]

        switch -- $padType {

            circle {
                set itemId [$canvas create oval \
                [expr {$sx - $sr}] \
                [expr {$sy - $sr}] \
                [expr {$sx + $sr}] \
                [expr {$sy + $sr}] \
                -fill orange \
                -outline {} \
                -tags [list pad $padName]]
            }

            square {
                set itemId [$canvas create rectangle \
                [expr {$sx - $sr}] \
                [expr {$sy - $sr}] \
                [expr {$sx + $sr}] \
                [expr {$sy + $sr}] \
                -fill cyan \
                -outline {} \
                -tags [list pad $padName]]
            }     
        }
        
    }
    
    
}
proc render::pads::highlightPad {canvas padName} {

    # clear previous selection
    foreach item [$canvas find withtag pad] {
        $canvas itemconfigure $item -outline {} -width 1
    }

    # highlight selected pad using tag
    foreach item [$canvas find withtag $padName] {
        $canvas itemconfigure $item -outline red -width [expr {(2 * $::view::scale * $::render::unitConversion)}]
    }
}
proc render::pads::clearSelection {canvas} {

    foreach item [$canvas find withtag pad] {
        $canvas itemconfigure $item -outline {} -width 1
    }
}
