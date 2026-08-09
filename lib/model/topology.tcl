namespace eval model::topology {}

# Retrieve structure dictionary by name or return dict if already provided
proc model::topology::getStructure {name} {
    if {[catch {dict exists $name id} hasId] == 0 && $hasId} {
        return $name
    }
    if {![info exists ::fanout::structures::registry($name)]} {
        error "Unknown structure: $name (available: [array names ::fanout::structures::registry])"
    }
    return $::fanout::structures::registry($name)
}

# Classify pad position and context within the BGA array
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

    if {$dRow < 0 && $dCol < 0} {
        set quadrant NW
    } elseif {$dRow < 0 && $dCol >= 0} {
        set quadrant NE
    } elseif {$dRow >= 0 && $dCol < 0} {
        set quadrant SW
    } else {
        set quadrant SE
    }

    set isTop    [expr {$padRow == 0}]
    set isBottom [expr {$padRow == ($rows - 1)}]
    set isLeft   [expr {$padCol == 0}]
    set isRight  [expr {$padCol == ($cols - 1)}]

    set edgePad [expr {$isTop || $isBottom || $isLeft || $isRight}]
    set edgeDirections [list]
    if {$isTop}    {lappend edgeDirections N}
    if {$isBottom} {lappend edgeDirections S}
    if {$isLeft}   {lappend edgeDirections W}
    if {$isRight}  {lappend edgeDirections E}

    return [dict create \
        row $padRow \
        col $padCol \
        dRow $dRow \
        dCol $dCol \
        ringDepth $ringDepth \
        quadrant $quadrant \
        edgePad $edgePad \
        edge $edgeDirections \
        rows $rows \
        cols $cols \
        centerRow $centerRow \
        centerCol $centerCol]
}

# Calculate allowed neck length based on structure rules or via/pad spacing constraints
proc model::topology::calculateAllowedNeckLength {structure bga} {
    if {[dict get $structure policy viaInPad]} {
        if {[dict get $structure via type] == "through"} {
            # Warning omitted as per instructions
        }
        return 0.0
    }
    if {[dict exists $structure rules neckLength]} {
        return [dict get $structure rules neckLength]
    } else {
        set spacingRules [dict get $structure spacing]
        set viaDef [dict get $structure via]
        set pitch [dict get $bga pitch]
        set totalViaDiameter [model::via::totalDiameter $viaDef]
        set bgaPadDiameter [dict get $bga padDiameter]
        set viaToPad [dict get $spacingRules viaToPadSpacing]

        set clearanceRadius [expr {($totalViaDiameter + $bgaPadDiameter)/2.0 + $viaToPad}]
        set neckLength [expr {$pitch - (($totalViaDiameter + $bgaPadDiameter)/2.0) - $viaToPad}]
        return $neckLength
    }
}

# Select escape direction based on policy: nearestEdge or quadrant only
proc model::topology::selectEscapeDirection {padContext structure bga} {
    set policy [dict get $structure policy escapePolicy]

    switch -- $policy {
        nearestEdge {
            return [model::topology::nearestEdgePolicy $padContext $bga]
        }
        quadrant {
            return [model::topology::quadrantPolicy $padContext]
        }
        default {
            error "Unknown or unsupported escape policy '$policy'"
        }
    }
}

# Nearest edge policy: select direction with minimum distance to BGA edge
proc model::topology::nearestEdgePolicy {padContext bga} {
    set row [dict get $padContext row]
    set col [dict get $padContext col]
    set rows [dict get $bga rows]
    set cols [dict get $bga cols]

    set distances [list\
        N $row \
        W $col \
        E [expr {($cols - 1) - $col}] \
        S [expr {($rows - 1) - $row}] \
    ]

    set selectedDirection ""
    set selectedDistance ""
    foreach {direction dist} $distances {
        if {$selectedDirection eq "" || $dist < $selectedDistance} {
            set selectedDirection $direction
            set selectedDistance $dist
        }
    }
    return $selectedDirection
}

# Quadrant policy: return quadrant as escape direction
proc model::topology::quadrantPolicy {padContext} {
    return [dict get $padContext quadrant]
}

# Map direction string to angle in degrees
proc model::topology::directionToAngle {escapeDirection} {
    switch -- $escapeDirection {
        N  { return 270 }
        S  { return 90 }
        E  { return 0 }
        W  { return 180 }
        NE { return 315 }
        NW { return 225 }
        SE { return 45 }
        SW { return 135 }
        default {
            error "Unknown direction '$escapeDirection'"
        }
    }
}

# Calculate channel width available for escape path
proc model::topology::calculateChannelWidth {pitch ballDiameter clearance} {
    return [expr {$pitch - $ballDiameter - 2.0 * $clearance}]
}

# Determine if channel width is sufficient for trace width routing
proc model::topology::isChannelValid {channelWidth traceWidth} {
    puts "Channel width: $channelWidth, Trace width: $traceWidth"
    return [expr {$channelWidth >= $traceWidth}]
}

# Calculate jog angle based on escape angle, ring depth, pitch, ball diameter, trace width, clearance
proc model::topology::calculatejogAngle {escapeAngle ringDepth pitch ballDiameter traceLength traceWidth clearance} {
    set channelWidth [model::topology::calculateChannelWidth $pitch $ballDiameter $clearance]
    
    if {![model::topology::isChannelValid $channelWidth $traceWidth]} {
        return $escapeAngle
    }
    
    set availableWidth [expr {$channelWidth - $traceWidth}]
    set maxjogOffset [expr {$pitch / 2}]
    # [expr {$availableWidth * ($ringDepth + 1)}]
    puts "Available width: $availableWidth, Max jog offset: $maxjogOffset"
    if {$maxjogOffset <= 0} {
        return $escapeAngle
    }
    set jogRadians [expr {atan($maxjogOffset / $pitch)}]
    set jogDegrees [expr {90 - $jogRadians * 180.0 / acos(-1)}]
    set ringIndex [expr {int($ringDepth)}]

    # Alternate jog direction by ringDepth parity
    set jogSign [expr {($ringIndex % 2) == 0 ? 1 : -1}]
    set jogAngle [expr {$escapeAngle + $jogSign * $jogDegrees}]
    puts "Calculated jog angle: $jogAngle (escape angle: $escapeAngle, ring depth: $ringDepth, max jog offset: $maxjogOffset)"
    return $jogAngle
}

# Generate escape plan dict with angle, neckLength and strategy
proc model::topology::generateEscapePlan {padContext structure bga} {
    set neckLength [model::topology::calculateAllowedNeckLength $structure $bga]
    set escapeDirection [model::topology::selectEscapeDirection $padContext $structure $bga]
    set escapeAngle [model::topology::directionToAngle $escapeDirection]
    return [dict create \
        angle $escapeAngle \
        neckLength $neckLength \
        strategy [dict get $structure policy escapePolicy]]
}

# Plan escape path as ordered list of abstract operations and plan-level metadata
proc model::topology::planEscapePath {padName pad padContext structure escapePlan bga} {
    set traceWidth [dict get $structure rules traceWidth]
    set pitch [dict get $bga pitch]
    set ballDiameter [dict get $bga padDiameter]
    set clearance [dict get $structure spacing viaToPadSpacing]

    set escapeAngle [dict get $escapePlan angle]
    set neckLength [dict get $escapePlan neckLength]
    set ringDepth [dict get $padContext ringDepth]

    set jogAngle [model::topology::calculatejogAngle $escapeAngle $ringDepth $pitch $ballDiameter $neckLength $traceWidth $clearance]

    set jogLength [expr {$pitch * 0.5}]

    set channelLength [expr {$pitch * ($ringDepth + 1) * 0.5}]

    set operations [list]

    lappend operations [dict create \
        id neck1 \
        type segment \
        angle $escapeAngle \
        length $neckLength \
        width $traceWidth \
        layer TOP]

    if {$ringDepth > 0} {
        lappend operations [dict create \
            id jog1 \
            type segment \
            angle $jogAngle \
            length $jogLength \
            width $traceWidth \
            layer TOP]
    }

    lappend operations [dict create \
        id escape1 \
        type segment \
        angle $escapeAngle \
        length $channelLength \
        width $traceWidth \
        layer TOP]

    return $operations
}

# Apply cline escape planning to pad, returning planned operations
proc model::topology::applyClineToPad {padName pad bga structureDef} {
    set structure [model::topology::getStructure $structureDef]
    set padContext [model::topology::classifyPad $pad $bga]
    set escapePlan [model::topology::generateEscapePlan $padContext $structure $bga]
    return [model::topology::planEscapePath $padName $pad $padContext $structure $escapePlan $bga]
}
