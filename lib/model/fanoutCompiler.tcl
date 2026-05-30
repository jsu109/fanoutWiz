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

proc model::fanoutCompiler::compileSegment {padId segName geometry width side laneId} {
    model::fanoutCompiler::requireExactKeys "pad $padId segment $segName geometry" \
        $geometry {x1 y1 x2 y2}

    return [dict create \
        id $segName \
        width $width \
        angle [model::fanoutCompiler::segmentAngle $geometry] \
        laneId $laneId \
        side $side \
        geometry $geometry \
        nodes [dict create \
            from $padId \
            to "$padId.$segName.exit" \
        ] \
    ]
}

proc model::fanoutCompiler::compile {fanout} {
    set padClines {}
    set pads [dict get $fanout pads]

    foreach padId [dict keys $pads] {
        set p [dict get $pads $padId]
        model::fanoutCompiler::requireKeys "pad $padId" $p {clines}

        set rawPadClines [dict get $p clines]
        model::fanoutCompiler::requireExactKeys "pad $padId padClines" \
            $rawPadClines {meta segments}

        set rawSegments [dict get $rawPadClines segments]
        model::fanoutCompiler::requireExactKeys "pad $padId padClines segments" \
            $rawSegments {neck escape}

        set meta [dict get $rawPadClines meta]
        model::fanoutCompiler::requireKeys "pad $padId padClines meta" \
            $meta {laneId side clineWidth}

        set width [dict get $meta clineWidth]

        set compiledSegments [dict create \
            neck [model::fanoutCompiler::compileSegment \
                $padId neck [dict get $rawSegments neck] $width \
                [dict get $meta side] [dict get $meta laneId]] \
            escape [model::fanoutCompiler::compileSegment \
                $padId escape [dict get $rawSegments escape] $width \
                [dict get $meta side] [dict get $meta laneId]] \
        ]

        dict set padClines $padId meta $meta
        dict set padClines $padId segments $compiledSegments
    }

    return $padClines
}
