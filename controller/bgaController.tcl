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

proc controller::build {} {

    $::render::canvas delete all

    set pads [model::bga::generatePads $::model::bga]

    set ::model::pads $pads

    set ::model::pads [render::pads::drawPads $::render::canvas $::model::pads $::model::bga]

    ui::bindings::attachPadSelection $::render::canvas
}

proc controller::applyAndEnableSelection {} {
    set rows [expr {int([.root.sidebar.geometry.rows.slider get])}]
    set cols [expr {int([.root.sidebar.geometry.cols.slider get])}]

    set ::model::bga [model::bga::createBGA $rows $cols]

    controller::build

    controller::setMode select

    ui::status::set "Selection enabled"
}