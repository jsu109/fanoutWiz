namespace eval model::fanout {}

proc model::fanout::resolveStructureName {structureName} {
    if {[info exists ::fanout::structures::registry($structureName)]} {
        return $structureName
    }

    return basic
}

proc model::fanout::createFanout {bga {structureName basic}} {
    set structureName [model::fanout::resolveStructureName $structureName]
    set pads [model::bga::generatePads $bga]
    set fanoutPads {}
    
    # TODO: add data to pads -> bgaSize: tuple {mxn} 
    foreach padId [dict keys $pads] {

        set id [dict get $pads $padId]
        # ---------------------------------------
        # CORRECT PAD ACCESS (flat structure)
        # ---------------------------------------
        set x [dict get $id x]
        set y [dict get $id y]

        set row [dict get $id row]
        set col [dict get $id col]
        set padClines [model::topology::applyClineToPad $padId $id $bga $structureName]
    
        # ---------------------------------------
        # BUILD FANOUT IR
        # ---------------------------------------
        dict set fanoutPads $padId row $row
        dict set fanoutPads $padId col $col
        dict set fanoutPads $padId position [dict create x $x y $y]
        dict set fanoutPads $padId clines $padClines
    }

    return [dict create \
        structure $structureName \
        bga [dict create \
            rows [dict get $bga rows] \
            cols [dict get $bga cols] \
            pitch [dict get $bga pitch] \
            padRadius [dict get $bga padRadius]] \
        pads $fanoutPads]
}
