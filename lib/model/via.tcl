namespace eval model::via {}

proc model::via::definitionFromStructure {{structureName basic}} {

    set structureName [model::via::resolveStructureName $structureName]
    set structure [model::topology::getStructure $structureName]

    if {![dict exists $structure via]} {
        error "Structure [dict get $structure id] missing via definition"
    }

    set viaDef [dict get $structure via]

    foreach key {holeDiameter annularRing} {
        if {![dict exists $viaDef $key]} {
            error "Structure [dict get $structure id] via missing required key: $key"
        }
    }

    if {![dict exists $viaDef type]} {
        dict set viaDef type through
    }

    return $viaDef
}
proc model::via::resolveStructureName {structureName} {
    if {[info exists ::fanout::structures::registry($structureName)]} {
        return $structureName
    }

    return basic
}

proc model::via::totalDiameter {viaDef} {
    return [expr {
        [dict get $viaDef holeDiameter] +
        2.0 * [dict get $viaDef annularRing]
    }]
}

proc model::via::createForPad {padId padClines {structureName basic}} {
    set structureName [model::via::resolveStructureName $structureName]
    set structure [model::topology::getStructure $structureName]
    
    set viaDef [model::via::definitionFromStructure $structure]
    set escapeGeometry [dict get $padClines segments escape]
    set diameter [model::via::totalDiameter $viaDef]

    return [dict create \
        id "$padId.via" \
        padId $padId \
        type [dict get $viaDef type] \
        holeDiameter [dict get $viaDef holeDiameter] \
        annularRing [dict get $viaDef annularRing] \
        diameter $diameter \
        geometry [dict create \
            x [dict get $escapeGeometry x2] \
            y [dict get $escapeGeometry y2] \
            radius [expr {$diameter / 2.0}]] \
        nodes [dict create \
            from "$padId.escape.exit" \
            to "$padId.via"]]
}

proc model::via::collectFromFanout {fanout} {
    set vias {}
    set pads [dict get $fanout pads]

    foreach padId [dict keys $pads] {
        set pad [dict get $pads $padId]
        if {[dict exists $pad via]} {
            dict set vias $padId [dict get $pad via]
        }
    }

    return $vias
}
