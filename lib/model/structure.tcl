namespace eval model::structure {}

proc model::structure::option {config path defaultValue} {
    if {[dict exists $config {*}$path]} {
        return [dict get $config {*}$path]
    }

    return $defaultValue
}

proc model::structure::mergeSection {structure config sectionName} {
    if {![dict exists $config $sectionName]} {
        puts "No section <$sectionName> in config; returning structure unchanged"
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
    puts [dict keys $config]
    set structureDef [model::structure::mergeSection $presetDef $config policy]
    set structureDef [model::structure::mergeSection $structureDef $config rules]
    set structureDef [model::structure::mergeSection $structureDef $config spacing]
    set structureDef [model::structure::mergeSection $structureDef $config via]
    # Get via definition: prioritize state config, fall back to preset
    set viaDef [dict get $structureDef via]
    
    if {[dict exists $config via]} {
        # State has a via definition; merge its rules with the preset's structure
        set stateVia [dict get $config via]
        if {[dict exists $stateVia rules]} {
            set presetVia [dict get $structureDef via]
            dict set viaDef rules [dict get $stateVia rules]
            # Preserve preset via metadata (type, id, etc.) but use state rules
            dict for {key value} $presetVia {
                if {$key ne "rules" && ![dict exists $viaDef $key]} {
                    dict set viaDef $key $value
                }
            }
        }
    }

    dict set structureDef via $viaDef

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
