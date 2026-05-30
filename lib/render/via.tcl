namespace eval render::via {}

proc render::via::drawVias {canvas frame} {
    if {![dict exists $frame vias]} {
        return
    }

    set vias [dict get $frame vias]

    set scale 1.0
    set ox 0
    set oy 0

    if {[info exists ::view::scale]} {
        set scale $::view::scale
    }

    if {[info exists ::view::offsetX]} {
        set ox $::view::offsetX
    }

    if {[info exists ::view::offsetY]} {
        set oy $::view::offsetY
    }

    dict for {padId via} $vias {
        set geom [dict get $via geometry]
        set x [expr {[dict get $geom x] * $scale + $ox}]
        set y [expr {[dict get $geom y] * $scale + $oy}]
        set radius [expr {[dict get $geom radius] * $scale}]
        set drillRadius [expr {([dict get $via holeDiameter] / 2.0) * $scale}]

        $canvas create oval \
            [expr {$x - $radius}] \
            [expr {$y - $radius}] \
            [expr {$x + $radius}] \
            [expr {$y + $radius}] \
            -fill "#caa947" \
            -outline "#ffe08a" \
            -width 1 \
            -tags [list via via-land $padId [dict get $via id]]

        $canvas create oval \
            [expr {$x - $drillRadius}] \
            [expr {$y - $drillRadius}] \
            [expr {$x + $drillRadius}] \
            [expr {$y + $drillRadius}] \
            -fill "#1e1e1e" \
            -outline "" \
            -tags [list via-drill $padId [dict get $via id]]
    }
}
