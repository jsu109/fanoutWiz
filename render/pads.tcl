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

                dict set pads $padName canvasId $itemId
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

                
                dict set pads $padName canvasId $itemId
            }     
        }
        
    }
    
    return $pads
}
proc render::pads::highlightPad {canvas padName} {

    set pads $::model::pads
    
    if {![dict exists $pads $padName]} {
        ui::status::set  "WARNING: pad not found: $padName"
        return
    }

    set padData [dict get $pads $padName]
    set id [dict get $padData canvasId]

    # reset all
    dict for {name data} $pads {
        if {[dict exists $data canvasId]} {
            $canvas itemconfigure [dict get $data canvasId] -outline {}
        }
    }

    # highlight selected
    $canvas itemconfigure $id \
        -outline red \
        -width 2
}
proc render::pads::clearSelection {canvas} {

    set pads $::model::pads

    dict for {name data} $pads {
        if {[dict exists $data canvasId]} {
            $canvas itemconfigure [dict get $data canvasId] \
                -outline {} \
                -width 1
        }
    }
}