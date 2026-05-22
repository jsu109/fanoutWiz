# drawPads
# drawPadLabels
# highlightPad

namespace eval render::pads {}

proc render::pads::drawPads {canvas pads bgaDef} {

    set radius [dict get $bgaDef padRadius]

    dict for {padName padData} $pads {

        set x [dict get $padData x]
        set y [dict get $padData y]

        set padType [dict get $padData type]

        switch -- $padType {

            circle {
                set itemId [$canvas create oval \
                [expr {$x - $radius}] \
                [expr {$y - $radius}] \
                [expr {$x + $radius}] \
                [expr {$y + $radius}] \
                -fill orange \
                -outline {} \
                -tags [list pad $padName]]
            }

            square {
                set itemId [$canvas create rectangle \
                [expr {$x - $radius}] \
                [expr {$y - $radius}] \
                [expr {$x + $radius}] \
                [expr {$y + $radius}] \
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
        $canvas itemconfigure $item -outline red -width 2
    }
}
proc render::pads::clearSelection {canvas} {

    foreach item [$canvas find withtag pad] {
        $canvas itemconfigure $item -outline {} -width 1
    }
}
