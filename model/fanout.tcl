namespace eval model::fanout {}

proc model::fanout::createFanout {pads directionSeed} {

    set fanoutPads {}
    
    foreach padId [dict keys $pads] {

        set p [dict get $pads $padId]
        # ---------------------------------------
        # CORRECT PAD ACCESS (flat structure)
        # ---------------------------------------
        set x [dict get $p x]
        set y [dict get $p y]

        set row [dict get $p row]
        set col [dict get $p col]

        # default direction
        set dir $directionSeed

        # ---------------------------------------
        # SIMPLE QUADRANT STRATEGY
        # ---------------------------------------
        if {$x >= 0 && $y >= 0} {
            set dir "N"
        } elseif {$x < 0 && $y >= 0} {
            set dir "W"
        } elseif {$x < 0 && $y < 0} {
            set dir "S"
        } else {
            set dir "E"
        }

        # ---------------------------------------
        # BUILD FANOUT IR
        # ---------------------------------------
        dict set fanoutPads $padId row $row
        dict set fanoutPads $padId col $col
        dict set fanoutPads $padId position [dict create x $x y $y]
        dict set fanoutPads $padId escape [dict create direction $dir]
        
    }
    
    return [dict create pads $fanoutPads]
}