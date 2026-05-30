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
    # offset = laneIndex * lanePitch
}
proc model::topology::generateEscapePlan {padContext structure bga} {
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
                laneId $lane \
                neckLength $neckLength]
}
# determine side cline should exit bga.
proc model::topology::selectSide {padContext structure bga} {
    set row [dict get $padContext row]
    set col [dict get $padContext col]
    set rows [dict get $bga rows]
    set cols [dict get $bga cols]

    set sideDepths [list \
        N $row \
        W $col \
        E [expr {($cols - 1) - $col}] \
        S [expr {($rows - 1) - $row}] \
    ]

    set selectedSide ""
    set selectedDepth ""
    foreach {side depth} $sideDepths {
        if {$selectedSide eq "" || $depth < $selectedDepth} {
            set selectedSide $side
            set selectedDepth $depth
        }
    }

    return $selectedSide
}
# determine lane index by depth from the selected BGA edge
proc model::topology::selectLane {padContext side structure bga} {
    set row [dict get $padContext row]
    set col [dict get $padContext col]
    set rows [dict get $bga rows]
    set cols [dict get $bga cols]

    switch -- $side {
        N {
            set edgeDepth $row
        }

        S {
            set edgeDepth [expr {($rows - 1) - $row}]
        }

        W {
            set edgeDepth $col
        }

        E {
            set edgeDepth [expr {($cols - 1) - $col}]
        }

        default {
            error "Unknown side: $side"
        }
    }

    if {$edgeDepth < 0} {
        error "Invalid edge depth for row $row col $col in ${rows}x${cols} BGA"
    }

    return $edgeDepth
}
proc model::topology::compileEscapePlan {padName pad padContext structure escapePlan bga} {

    set side [dict get $escapePlan side]
    set laneId [dict get $escapePlan laneId]
    set neckLength [dict get $escapePlan neckLength]
    set structureName [dict get $structure id]

    set x [dict get $pad x]
    set y [dict get $pad y]

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
    set lanePitch [expr {
        [dict get $structure rules traceWidth] +
        [dict get $structure rules traceSpacing]
    }]
    set offset [expr {($laneId + 1) * $lanePitch}]

    # --------------------
    # ESCAPE segment
    # --------------------
    switch $side {
        N {
            set ex1 $x2
            set ey1 $y2
            set ex2 $x2
            set ey2 [expr {$y2 - $offset}]
        }
        S {
            set ex1 $x2
            set ey1 $y2
            set ex2 $x2
            set ey2 [expr {$y2 + $offset}]
        }
        E {
            set ex1 $x2
            set ey1 $y2
            set ex2 [expr {$x2 + $offset}]
            set ey2 $y2
        }
        W {
            set ex1 $x2
            set ey1 $y2
            set ex2 [expr {$x2 - $offset}]
            set ey2 $y2
        }
    }

    dict set segments escape [dict create x1 $ex1 y1 $ey1 x2 $ex2 y2 $ey2]

    # --------------------
    # META
    # --------------------
    set meta [dict create \
        padId $padName \
        side $side \
        laneId $laneId \
        structure $structureName \
        clineWidth [dict get $structure rules traceWidth] \
    ]

    return [dict create \
        meta $meta \
        segments $segments]
}

proc model::topology::applyClineToPad {padName pad bga structureName} {

    # Fanout IR v1 padClines, completed by model::fanoutCompiler::compile:
    # padClines = {
    #     meta {
    #         padId A1
    #         side N
    #         laneId 3
    #         structure basic
    #     }
    #     segments {
    #         neck   {id width angle laneId side geometry nodes}
    #         escape {id width angle laneId side geometry nodes}
    #     }
    # }
    
    set structure [model::topology::getStructure $structureName]
    
    set padContext [model::topology::classifyPad $pad $bga]
    
    set escapePlan [model::topology::generateEscapePlan $padContext $structure $bga]
    set padCline [model::topology::compileEscapePlan \
        $padName $pad $padContext $structure $escapePlan $bga]

    return $padCline

}
