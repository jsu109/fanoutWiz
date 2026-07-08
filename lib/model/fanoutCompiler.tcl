namespace eval model::fanoutCompiler {}

proc model::fanoutCompiler::requireKeys {label value requiredKeys} {
    foreach key $requiredKeys {
        if {![dict exists $value $key]} {
            error "$label missing required key: $key"
        }
    }
}

proc model::fanoutCompiler::requireExactKeys {label value expectedKeys} {
    model::fanoutCompiler::requireKeys $label $value $expectedKeys

    foreach key [dict keys $value] {
        if {[lsearch -exact $expectedKeys $key] < 0} {
            error "$label contains unsupported key: $key"
        }
    }
}

proc model::fanoutCompiler::segmentAngle {geometry} {
    set dx [expr {[dict get $geometry x2] - [dict get $geometry x1]}]
    set dy [expr {[dict get $geometry y2] - [dict get $geometry y1]}]

    if {$dx == 0 && $dy == 0} {
        return 0
    }

    return [expr {atan2($dy, $dx) * 180.0 / acos(-1)}]
}

# FIX: "layer" is required and returned again — it was being silently
# dropped, which would have been invisible until something downstream
# needed to know what layer a segment was on.
proc model::fanoutCompiler::compileSegment {padId segment} {
    puts "padId: $padId, segment: $segment"
    model::fanoutCompiler::requireKeys \
        "pad $padId segment" \
        $segment {id type width layer geometry}

    set geometry [dict get $segment geometry]

    return [dict create \
        id       [dict get $segment id] \
        type     [dict get $segment type] \
        width    [dict get $segment width] \
        layer    [dict get $segment layer] \
        angle    [model::fanoutCompiler::segmentAngle $geometry] \
        geometry $geometry]
}

# unchanged — this one was already correct
proc model::fanoutCompiler::compileVia {padId via} {
    model::fanoutCompiler::requireExactKeys \
        "pad $padId via [dict get $via id]" \
        $via {id viaTypeId location fromLayer toLayer padstack}

    return [dict create \
        id        [dict get $via id] \
        viaTypeId [dict get $via viaTypeId] \
        location  [dict get $via location] \
        fromLayer [dict get $via fromLayer] \
        toLayer   [dict get $via toLayer] \
        padstack  [dict get $via padstack] \
    ]
}

# unchanged — still generic over an arbitrary ordered sequence
proc model::fanoutCompiler::chainNodes {padId compiledSegments compiledVias} {
    set nodes {}
    set previous $padId
    foreach seg $compiledSegments {
        set exitId "$padId.[dict get $seg id].exit"
        dict set nodes [dict get $seg id] [dict create from $previous to $exitId]
        set previous $exitId
    }
    foreach via $compiledVias {
        set exitId "$padId.[dict get $via id].exit"
        dict set nodes [dict get $via id] [dict create from $previous to $exitId]
        set previous $exitId
    }
    return [dict create nodes $nodes final $previous]
}

proc model::fanoutCompiler::compileEscapePath {padId escapePath} {
    puts "escapePath: $escapePath"
    model::fanoutCompiler::requireKeys "escapePath" \
        $escapePath {padRef startPad operations}
    # todo: get the position for first seg using the padRef and the padContext
    set position [dict get $escapePath startPad]
    set currentLayer TOP
    set compiledSegments {}
    set compiledVias {}

    foreach operation [dict get $escapePath operations] {
        set type [dict get $operation type]

        switch $type {
            segment {
                set angle [dict get $operation angle]
                set length [dict get $operation length]
                set width [dict get $operation width]

                set radians [expr {$angle * acos(-1) / 180.0}]
                set x1 [dict get $position x]
                set y1 [dict get $position y]
                set x2 [expr {$x1 + $length * cos($radians)}]
                set y2 [expr {$y1 + $length * sin($radians)}]

                set segment [dict create \
                    id [dict get $operation id] \
                    type segment \
                    width $width \
                    layer [dict get $operation layer] \
                    angle $angle \
                    geometry [dict create \
                        x1 $x1 y1 $y1 \
                        x2 $x2 y2 $y2]]

                lappend compiledSegments $segment
                set position [dict create x $x2 y $y2]
                set currentLayer [dict get $operation layer]
            }

            via {
                # Via compilation will be added when via operations are introduced.
                lappend compiledVias [dict create \
                    id [dict get $operation id] \
                    location $position]
            }

            default {
                error "Unknown escape operation type: $type"
            }
        }
    }

    set chain [model::fanoutCompiler::chainNodes $padId $compiledSegments $compiledVias]

    return [dict create \
        padRef   [dict get $escapePath padRef] \
        segments $compiledSegments \
        vias     $compiledVias \
        nodes    [dict get $chain nodes] \
        endpoint $position ]
}

# NEW: pulled out of compile() so the migration bridge has a name, a
# comment explaining its lifespan, and can be deleted in one place once
# model::structure::createStructure emits EscapePath[] natively.
#
# FIX: "status" now defaults to "ok" instead of hard-requiring the key —
# legacy pad data may predate the status concept entirely.
#
# TODO: remove this proc (and its call site in compile()) once
# createStructure no longer produces the row/col/position/clines/via shape.
proc model::fanoutCompiler::legacyPadToEscapePath {padId padData} {
    if {[dict exists $padData clines status]} {
        set status [dict get $padData clines status]
    } else {
        set status ok
    }

    set escapePath [dict create \
        padRef   $padId \
        startPad [dict get $padData position] \
        segments [dict get $padData clines segments] \
        vias     {} \
        endpoint [dict get $padData clines endpoint] \
        status   $status \
    ]

    if {[dict exists $padData via]} {
        set via [dict get $padData via]
        dict set escapePath vias [dict create [dict get $via id] $via]
    }

    return $escapePath
}


proc model::fanoutCompiler::compile {fanout} {
    set compiled {}

    # Support structure output where pads still contain
    # row/col/position/clines/via and convert it into EscapePath IR.
    if {[dict exists $fanout pads]} {
        set fanout [dict get $fanout pads]
    }

    foreach padId [dict keys $fanout] {
        set padData [dict get $fanout $padId]
        if {[dict exists $padData clines]} {
            set escapePath [model::fanoutCompiler::legacyPadToEscapePath $padId $padData]
        } else {
            set escapePath $padData
        }
        dict set compiled $padId \
            [model::fanoutCompiler::compileEscapePath $padId $escapePath]
    }
    return $compiled
}