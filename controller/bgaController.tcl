namespace eval controller {}

proc controller::setMode {mode} {

    set ::model::mode $mode

    if {![winfo exists .root.sidebar.geometry.rows.slider]} {
        return
    }

    if {$mode eq "select"} {

        .root.sidebar.geometry.rows.slider configure -state disabled
        .root.sidebar.geometry.cols.slider configure -state disabled

        .root.sidebar.modeValue configure -text "SELECT"

    } else {

        .root.sidebar.geometry.rows.slider configure -state normal
        .root.sidebar.geometry.cols.slider configure -state normal

        .root.sidebar.modeValue configure -text "EDIT"
    }
}
proc controller::toggleMode {} {

    if {$::model::mode eq "edit"} {

        controller::applyAndEnableSelection

        .root.sidebar.modeToggle configure -text "Switch to EDIT"

    } else {

        controller::setMode edit

        .root.sidebar.modeToggle configure -text "Switch to SELECT"

    }

}

proc controller::isEditMode {} {
    return [expr {$::model::mode eq "edit"}]
}

proc controller::applyBGA {} {

    if {![controller::isEditMode]} {
        return
    }
    set rows [expr {int([.root.sidebar.geometry.rows.slider get])}]
    set cols [expr {int([.root.sidebar.geometry.cols.slider get])}]

    set ::model::bga [model::bga::createBGA $rows $cols]
    
    controller::build
}
proc controller::collectFrame {} {

    set bga $::model::bga
    set seg $::model::clineSeg

    set pads [model::bga::generatePads $bga]
    set fanout [model::fanout::createFanout $pads "N"] 

    set segs [model::fanoutCompiler::compile $fanout]
    
    set cols [dict get $bga cols]
    set rows [dict get $bga rows]
    set pitch [dict get $bga pitch]
    set padRadius [dict get $bga padRadius]

    set halfWidth  [expr {(($cols - 1) * $pitch) / 2.0}]
    set halfHeight [expr {(($rows - 1) * $pitch) / 2.0}]

    set worldW [expr {2 * ($halfWidth + $padRadius)}]
    set worldH [expr {2 * ($halfHeight + $padRadius)}]

    return [dict create \
        pads $pads \
        segs $segs \
        worldW $worldW \
        worldH $worldH]
}

proc controller::build {} {

    $::render::canvas delete all

    # Single source of truth for renderable scene bounds
    set frame [controller::collectFrame]
    set ch [winfo height $::render::canvas]
    set cw [winfo width $::render::canvas]
    set worldW [dict get $frame worldW]
    set worldH [dict get $frame worldH]

    view::fit $worldW $worldH $cw $ch

    render::fanout::draw $::render::canvas $frame
    
    
    ui::bindings::attachPadSelection $::render::canvas
}

proc controller::applyAndEnableSelection {} {
    set rows [expr {int([.root.sidebar.geometry.rows.slider get])}]
    set cols [expr {int([.root.sidebar.geometry.cols.slider get])}]

    set ::model::bga [model::bga::createBGA $rows $cols]

    

    # controller::setMode select

    ui::status::set "Selection enabled"
    controller::build
}