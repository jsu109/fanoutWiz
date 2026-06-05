namespace eval model::topology {}

if {![llength [info commands ui::status::set]]} {
    namespace eval ui::status {}
    proc ui::status::set {msg} {}
}

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
    # if {abs($dRow) < 0.5 && abs($dCol) < 0.5} {
    # set quadrant CENTER
    # }

    # Determine edge (logic assumes row/col 0th start index). 

    set isTop    [expr {$padRow == 0}]
    set isBottom [expr {$padRow == ($rows - 1)}]
    set isLeft   [expr {$padCol == 0}]
    set isRight  [expr {$padCol == ($cols - 1)}]

    set edgePad [expr {$isTop || $isBottom || $isLeft || $isRight}]
    set edgeescapeDirection [list]
    if {$isTop}    {lappend edgeescapeDirection "TOP"}
    if {$isBottom} {lappend edgeescapeDirection "BOTTOM"}
    if {$isLeft}   {lappend edgeescapeDirection "LEFT"}
    if {$isRight}  {lappend edgeescapeDirection "RIGHT"}
    
    set padContext [dict create \
                        row $padRow \
                        col $padCol \
                        dRow $dRow \
                        dCol $dCol \
                        ringDepth $ringDepth\
                        quadrant $quadrant \
                        edgePad $edgePad\
                        edge $edgeescapeDirection]\
                        
    return $padContext
    
}

proc model::topology::angleToVector {escapeDirection} {

    set rad [expr {$angleDeg * acos(-1) / 180.0}]

    set dx [expr {cos($rad)}]

    set dy [expr {-sin($rad)}] ;# PCB Y-axis inverted

    return [list $dx $dy]

}
proc model::topology::directionVector {escapeDirection} {
    switch -- $escapeDirection {
        N  { return { 0 -1 } }
        S  { return { 0  1 } }
        E  { return { 1  0 } }
        W  { return {-1  0 } }
        NE { return { 1 -1 } }
        NW { return {-1 -1 } }
        SE { return { 1  1 } }
        SW { return {-1  1 } }
        default {
            error "Unknown direction '$escapeDirection'"
        }
    }
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

proc model::topology::quadrantEscape {padContext} {
}


proc model::topology::calculateAllowedNeckLength {structure bga} {
    # check for VIPPO Policy
    if {[dict get $structure policy viaInPad]} { 
        if {[dict get $structure via type] == "through"} {
            ui::status::set "warning Via Type set to Through"
        }
        set neckLength 0.0
    } else {
        set spacingRules [dict get $structure spacing] 
        set viaDef [dict get $structure via]
        set rules [dict get $viaDef rules]
        
        set pitch [dict get $bga pitch]
        set totalViaDiameter [model::via::totalDiameter $viaDef]
        set bgaPadDiameter [dict get $bga padDiameter]
        set viaToPad [dict get $spacingRules viaToPadSpacing]
        
        set clearanceRadius [expr {($totalViaDiameter + $bgaPadDiameter)/2.0 + $viaToPad}]
        
        set neckLength [expr {$pitch - (($totalViaDiameter + $bgaPadDiameter) / 2.0) - $viaToPad}]
        # puts [units::um $neckLength]
    }
    return [units::um $neckLength]
}
proc model::topology::generateEscapePlan {padContext structure bga} {
    set neckLength [model::topology::calculateAllowedNeckLength $structure $bga]


    # determine escapeDirection
    set escapeDirection [model::topology::selectEscapeDirection \
                    $padContext \
                    $structure \
                    $bga]

    # # determine lane
    # set lane [model::topology::selectLane \
    #                 $padContext \
    #                 $escapeDirection \
    #                 $structure \
    #                 $bga]

    return [dict create \
                escapeDirection $escapeDirection \
                neckLength $neckLength]
}
# determine escapeDirection cline should exit bga.
proc model::topology::selectEscapeDirection {padContext structure bga} {


    set policy [dict get $structure policy escapePolicy]

    switch -- $policy {
        nearestEdge {
            return [model::topology::nearestEdgePolicy $padContext $bga]
        }

        quadrant {
            return [model::topology::quadrantPolicy $padContext]
        }

        horizontalFirst {
            return [model::topology::horizontalFirstPolicy $depths]
        }

        verticalFirst {
            return [model::topology::verticalFirstPolicy $depths]
        }

        default {
            error "Unknown escape policy '$policy'"
        }
    }
}

proc model::topology::nearestEdgePolicy {padContext bga} {
    set row [dict get $padContext row]
    set col [dict get $padContext col]
    set rows [dict get $bga rows]
    set cols [dict get $bga cols]

    set escapeDirectionDepths [list \
        N $row \
        W $col \
        E [expr {($cols - 1) - $col}] \
        S [expr {($rows - 1) - $row}] \
    ]

    set selectedescapeDirection ""
    set selectedDepth ""
    foreach {escapeDirection depth} $escapeDirectionDepths {
        if {$selectedescapeDirection eq "" || $depth < $selectedDepth} {
            set selectedescapeDirection $escapeDirection
            set selectedDepth $depth
        }
    }

    return $selectedescapeDirection
}
proc model::topology::quadrantPolicy {padContext} {
    return [dict get $padContext quadrant]
}
# determine lane index by depth from the selected BGA edge
proc model::topology::selectLane {padContext escapeDirection structure bga} {
    set row [dict get $padContext row]
    set col [dict get $padContext col]
    set rows [dict get $bga rows]
    set cols [dict get $bga cols]

    switch -- $escapeDirection {
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
            error "Unknown escapeDirection: $escapeDirection"
        }
    }

    if {$edgeDepth < 0} {
        error "Invalid edge depth for row $row col $col in ${rows}x${cols} BGA"
    }

    return $edgeDepth
}
proc model::topology::compileEscapePlan {padName pad padContext structure escapePlan bga} {

    set escapeDirection     [dict get $escapePlan escapeDirection]
    # set laneId   [dict get $escapePlan laneId]
    set neckLength [dict get $escapePlan neckLength]
    set structureName [dict get $structure id]
    set x [dict get $pad x]
    set y [dict get $pad y]

    if {[string is double -strict $escapeDirection]} {
        set v [model::topology::angleToVector $escapeDirection]
    } else {
        set v [model::topology::directionVector $escapeDirection]
    }
    lassign $v dx dy

    set x1 $x

    set y1 $y

    set x2 [expr {$x + $dx * $neckLength}]

    set y2 [expr {$y + $dy * $neckLength}]

    set neck [dict create \
        x1 $x1 y1 $y1 x2 $x2 y2 $y2]
    # --------------------
    # META
    # --------------------
    set meta [dict create \
        padId $padName \
        escapeDirection $escapeDirection \
        structure $structureName \
        clineWidth [dict get $structure rules traceWidth]]

    # --------------------
    # OUTPUT (neck only)
    # --------------------
    return [dict create \
        meta $meta \
        neck $neck]
}

proc model::topology::applyClineToPad {padName pad bga structureName} {

    # Fanout IR v1 padClines, completed by model::fanoutCompiler::compile:
    # padClines = {
    #     meta {
    #         padId A1
    #         escapeDirection N
    #         laneId 3
    #         structure basic
    #     }
    #     segments {
    #         neck   {id width angle laneId escapeDirection geometry nodes}
    #         escape {id width angle laneId escapeDirection geometry nodes}
    #     }
    # }
    
    set structure [model::topology::getStructure $structureName]
    set padContext [model::topology::classifyPad $pad $bga]
    
    set escapePlan [model::topology::generateEscapePlan $padContext $structure $bga]
    set padCline [model::topology::compileEscapePlan \
        $padName $pad $padContext $structure $escapePlan $bga]
    return $padCline

}
