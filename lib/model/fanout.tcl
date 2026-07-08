namespace eval model::fanout {}

proc model::fanout::getEscapeEndpoint {segments via} {
    if {[dict exists $via geometry x] && [dict exists $via geometry y]} {
        return [dict create \
            x [dict get $via geometry x] \
            y [dict get $via geometry y]]
    }

    set lastSeg [lindex [dict keys $segments] end]
    return [dict create \
        x [dict get $segments $lastSeg geometry x2] \
        y [dict get $segments $lastSeg geometry y2]]
}

proc model::fanout::resolveStructureName {structureName} {
    if {[catch {dict exists $structureName id} hasId] == 0 && $hasId} {
        return [dict get $structureName id]
    }

    if {[info exists ::fanout::structures::registry($structureName)]} {
        return $structureName
    }

    return basic
}

proc model::fanout::createFanout {bga {structureName basic}} {
    set structure [model::topology::getStructure $structureName]
    set structureId [dict get $structure id]
    set bgaRules [model::bga::deriveRules $bga]
    set pads [model::bga::generatePads $bga]
    set fanoutPads {}
    
    foreach padId [dict keys $pads] {

        set id [dict get $pads $padId]
        # ---------------------------------------
        # CORRECT PAD ACCESS (flat structure)
        # ---------------------------------------
        set x [dict get $id x]
        set y [dict get $id y]

        set row [dict get $id row]
        set col [dict get $id col]
        set padClines [model::topology::applyClineToPad $padId $id $bga $structure]
        set padContext [model::topology::classifyPad $id $bga]
        # set via [model::via::createForPad $padId $padClines $padContext $structure]
        
        # ---------------------------------------
        # BUILD FANOUT IR
        # ---------------------------------------
        # vias [list $via]
        set escapePath [dict create \
            padRef $padId \
            startPad [dict create x $x y $y] \
            operations $padClines \
            
            ]
        dict set fanoutPads $padId $escapePath
    }

    return [dict create \
        structure $structureId \
        bga [dict create \
            rows [dict get $bga rows] \
            cols [dict get $bga cols] \
            pitch [dict get $bga pitch] \
            ballDiameter [dict get $bga ballDiameter] \
            padScale [dict get $bga padScale] \
            padDiameter [dict get $bga padDiameter] \
            padRadius [dict get $bga padRadius] \
            rules $bgaRules] \
        routingRules [dict get $structure rules] \
        viaDefinition [dict get $structure via] \
        pads $fanoutPads]
}
