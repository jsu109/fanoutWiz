namespace eval model::structure {}

proc model::structure::option {config path defaultValue} {
    if {[dict exists $config {*}$path]} {
        return [dict get $config {*}$path]
    }

    return $defaultValue
}

proc model::structure::mergeSection {structure config sectionName} {
    if {![dict exists $config $sectionName]} {
        return $structure
    }

    set section [model::structure::option $structure [list $sectionName] [dict create]]
    dict for {key value} [dict get $config $sectionName] {
        dict set section $key $value
    }
    dict set structure $sectionName $section

    return $structure
}

proc model::structure::createStructure {config} {
    set preset [model::fanout::resolveStructureName \
        [model::structure::option $config {preset} \
            [model::structure::option $config {id} basic]]]
    set presetDef [model::topology::getStructure $preset]

    set bgaConfig [model::structure::option $config {bga} [dict create]]
    set rows [model::structure::option $bgaConfig {rows} 5]
    set cols [model::structure::option $bgaConfig {cols} 5]

    set bgaOptions [dict create]
    foreach key {pitch ballDiameter padScale padDiameter defaultPadType} {
        if {[dict exists $bgaConfig $key]} {
            dict set bgaOptions $key [dict get $bgaConfig $key]
        }
    }

    set bga [model::bga::createBGA $rows $cols $bgaOptions]
    set structureDef [model::structure::mergeSection $presetDef $config policy]
    set structureDef [model::structure::mergeSection $structureDef $config rules]
    set structureDef [model::structure::mergeSection $structureDef $config spacing]

    if {[dict exists $config vias active]} {
        dict set structureDef via [dict get $config vias active]
    } elseif {[dict exists $config via]} {
        dict set structureDef via [dict get $config via]
    }

    set pads [model::bga::generatePads $bga]
    set fanout [model::fanout::createFanout $bga $structureDef]
    set vias [model::via::collectFromFanout $fanout]

    return [dict create \
        preset $preset \
        bga $bga \
        pads $pads \
        fanout $fanout \
        vias $vias \
        rules [dict get $structureDef rules] \
        policy [dict get $structureDef policy] \
        spacing [dict get $structureDef spacing] \
        viaDefinition [dict get $structureDef via] \
        metadata [dict create \
            generatedAt [clock seconds] \
            sourceConfig $config]]
}
