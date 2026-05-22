namespace eval view {
    variable scale 1.0
    variable offsetX 0
    variable offsetY 0
}

proc view::setZoom {s} {
    variable scale
    set scale $s
}

proc view::setOffset {x y} {
    variable offsetX
    variable offsetY

    set offsetX $x
    set offsetY $y
}

proc view::fit {bw bh cw ch} {
    variable scale
    variable offsetX
    variable offsetY

    set margin 100.0

    set usableW [expr {$cw - 2*$margin}]
    set usableH [expr {$ch - 2*$margin}]

    set sx [expr {$usableW / double($bw)}]
    set sy [expr {$usableH / double($bh)}]

    set scale [expr {$sx < $sy ? $sx : $sy}]

    set offsetX [expr {($cw/2.0)}]
    set offsetY [expr {($ch/2.0)}]
}