namespace eval model::topology {}


proc model::topology::getTopologyProc {structure} {

    dict get {
        orthogonal model::topology::orthogonalEscape
        diagonal   model::topology::diagonalEscape
        NSEW  model::topology::NSEW
    } $structure
}
proc model::topology::getStructure {name} {

    if {![info exists ::fanout::structures::registry($name)]} {
        error "Unknown structure: $name (available: [array names ::fanout::structures::registry])"
    }

    return $::fanout::structures::registry($name)
}

proc model::topology::classifyPad {padId bga} {
    set rows [dict get $bga rows]
    set cols [dict get $bga cols]
    
    set padRow [dict get $padId row]
    set padCol [dict get $padId col]

    set centerRow [expr {($rows - 1) / 2.0}]
    set centerCol [expr {($cols - 1) / 2.0}]

    set dRow [expr {$padRow - $centerRow}]
    set dCol [expr {$padCol - $centerCol}]
    
    set ringDepth [expr {max(abs($dRow), abs($dCol))}]
    
    # NW dRow <0, dCol <0
    # NE dRow <0, dCol >0
    # SW dRow >0, dCol <0
    # SE dRow >0, dCol >0

    # Determine quadrant
    if {$dRow < 0 && $dCol < 0} {
        set quadrant NW
    } elseif {$dRow < 0 && $dCol >= 0} {
        set quadrant NE
    } elseif {$dRow >= 0 && $dCol < 0} {
        set quadrant SW
    } else {
        set quadrant SE
    }
    if {abs($dRow) < 0.5 && abs($dCol) < 0.5} {
    set quadrant CENTER
    }

    # Determine edge (logic assumes row/col 0th start index). 

    set isTop    [expr {$padRow == 0}]
    set isBottom [expr {$padRow == ($rows - 1)}]
    set isLeft   [expr {$padCol == 0}]
    set isRight  [expr {$padCol == ($cols - 1)}]

    set edgePad [expr {$isTop || $isBottom || $isLeft || $isRight}]
    set edgeSide [list]
    if {$isTop}    {lappend edgeSide "TOP"}
    if {$isBottom} {lappend edgeSide "BOTTOM"}
    if {$isLeft}   {lappend edgeSide "LEFT"}
    if {$isRight}  {lappend edgeSide "RIGHT"}
    
    set padContext [dict create \
                        row $padRow \
                        col $padCol \
                        dRow $dRow \
                        dCol $dCol \
                        ringDepth $ringDepth\
                        quadrant $quadrant \
                        edge $edgeSide]\
                        
    return $padContext
    
}
proc model::topology::orthogonalEscape {padContext} {
    # Given:
    #   - pad identity
    #   - BGA dimensions
    #   - topology strategy

    # Determine:
    #   - routing class
    #   - preferred escape direction
    #   - topology parameters
    
    # length = neckoutDistance
    # offset = laneIndex * lanebgaPitch

    puts $padContext

    
}
proc model::topology::generateEscapePlan {padContext structure bga} {
    
    set quadrant [dict get $padContext quadrant]
    set ringDepth [dict get $padContext ringDepth]

    set neckLength [dict get $structure rules neckLength]

    # determine side
    set side [model::topology::selectSide \
                    $padContext \
                    $structure \
                    $bga]

    # determine lane
    set lane [model::topology::selectLane \
                    $padContext \
                    $side \
                    $structure \
                    $bga]

    return [dict create \
                side $side \
                lane $lane \
                neckLength $neckLength]
}
# determine side cline should exit bga.
proc model::topology::selectSide {padContext structure bga} {

    set dRow [dict get $padContext dRow]
    set dCol [dict get $padContext dCol]

    if {abs($dRow) > abs($dCol)} {

        if {$dRow < 0} {
            return N
        } else {
            return S
        }

    } else {

        if {$dCol < 0} {
            return W
        } else {
            return E
        }
    }
}
# determine lane
proc model::topology::selectLane {padContext side structure bga} {

    set row [dict get $padContext row]
    set col [dict get $padContext col]

    switch -- $side {
        N -
        S {
            return $col
        }

        E -
        W {
            return $row
        }

        default {
            error "Unknown side: $side"
        }
    }
}
proc model::topology::compileEscapePlan {padId padContext structure escapePlan bga} {

    set side [dict get $escapePlan side]
    set lane [dict get $escapePlan lane]
    set neckLength [dict get $escapePlan neckLength]

    set row [dict get $padContext row]
    set col [dict get $padContext col]

    # assume bgaPitch (you may already have this in bga later)
    set bgaPitch [dict get $bga pitch]
    puts [dict keys $padId]
    set originX [dict get $padId x]
    set originY [dict get $padId y]

    set x [expr {$originX + $col * $bgaPitch}]
    set y [expr {$originY + $row * $bgaPitch}]

    set segments {}

    # --------------------
    # NECK segment
    # --------------------
    switch $side {
        N {
            set x1 $x
            set y1 $y
            set x2 $x
            set y2 [expr {$y - $neckLength}]
        }
        S {
            set x1 $x
            set y1 $y
            set x2 $x
            set y2 [expr {$y + $neckLength}]
        }
        E {
            set x1 $x
            set y1 $y
            set x2 [expr {$x + $neckLength}]
            set y2 $y
        }
        W {
            set x1 $x
            set y1 $y
            set x2 [expr {$x - $neckLength}]
            set y2 $y
        }
    }

    dict set segments neck [dict create x1 $x1 y1 $y1 x2 $x2 y2 $y2]

    # --------------------
    # LANE OFFSET (simple model)
    # --------------------
    set lanebgaPitch [dict get $structure rules lanePitch]
    set offset [expr {$lane * $lanebgaPitch}]

    # --------------------
    # ESCAPE segment
    # --------------------
    switch $side {
        N -
        S {
            set ex1 $x2
            set ey1 $y2
            set ex2 [expr {$x2 + $offset}]
            set ey2 $y2
        }
        E -
        W {
            set ex1 $x2
            set ey1 $y2
            set ex2 $x2
            set ey2 [expr {$y2 + $offset}]
        }
    }

    dict set segments escape [dict create x1 $ex1 y1 $ey1 x2 $ex2 y2 $ey2]

    # --------------------
    # META
    # --------------------
    set meta [dict create \
        padId $padId \
        side $side \
        lane $lane \
        structure "dogbone" \
    ]

    return [dict create \
        meta $meta \
        segments $segments]
}

proc model::topology::applyClineToPad {padId bga structrueName} {

    # TODO: create a Cline object which is definthed by the following proposed data structure
    # padClines = {
    #     meta {
    #         padId A1
    #         structure dogbone
    #         side N
    #         lane 3
    #     }

    #     segments {
    #         neck   {x1 y1 x2 y2}
    #         jog    {x1 y1 x2 y2}
    #         escape {x1 y1 x2 y2}
    #     }
    # }
    # ClineSegs with a defined Width, length, angle. based on the required
    # structure, bga size and pin location. 
    
    # set topologyProc [model::topology::getTopologyProc $structrueName]
    set structure [model::topology::getStructure $structrueName]
    
    set padContext [model::topology::classifyPad $padId $bga]
    
    set escapePlan [model::topology::generateEscapePlan $padContext $structure $bga]
    set padCline [model::topology::compileEscapePlan $padId $padContext $structure $escapePlan $bga]

    # puts $padCline
    return $padCline

}

