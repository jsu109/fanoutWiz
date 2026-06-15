namespace eval render::figs {}

proc render::figs::drawCross {position} {
    lassign $position x y

    set x [view::scaleX $x]
    set y [view::scaleY $y]
    set halfSize [view::scale 5]

    set canvas $::ui::canvas
    $canvas create line [expr {$x - $halfSize}] $y [expr {$x + $halfSize}] $y \
        -fill white -width 2
    $canvas create line $x [expr {$y - $halfSize}] $x [expr {$y + $halfSize}] \
        -fill white -width 2
}

proc render::figs::drawline {canvas pos1 pos2} {
   

   set x1 [dict get $pos1 x]
   set y1 [dict get $pos1 y]
   set x2 [dict get $pos2 x]
   set y2 [dict get $pos2 y]

# -----------------------------
    # view transform
    # -----------------------------
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

        # -----------------------------
        # transform
        # -----------------------------
        set x1 [expr {$x1 * $scale + $ox}]
        set y1 [expr {$y1 * $scale + $oy}]
        set x2 [expr {$x2 * $scale + $ox}]
        set y2 [expr {$y2 * $scale + $oy}]

        # -----------------------------
        # draw
        # -----------------------------
        set lineWidth [expr {1 * $scale}]

        $canvas create line \
            $x1 $y1 $x2 $y2 \
            -fill white \
            -width $lineWidth \
            
        # need to work out how to do tags so i can keep track of these lines
}