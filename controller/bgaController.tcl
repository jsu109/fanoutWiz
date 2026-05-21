namespace eval controller {}


proc controller::setMode {mode} {
    set ::model::mode $mode

    if {$mode eq "select"} {
        .controls.rows configure -state disabled
        .controls.cols configure -state disabled
    } else {
        .controls.rows configure -state normal
        .controls.cols configure -state normal
    }
}

proc controller::isEditMode {} {
    return [expr {$::model::mode eq "edit"}]
}
proc controller::applyBGA {} {
    if {![controller::isEditMode]} {

        return

    }
    set rows [.controls.rows get]
    set cols [.controls.cols get]

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

    # read sliders
    set rows [expr {int([.controls.rows get])}]
    set cols [expr {int([.controls.cols get])}]

    # update model
    set ::model::bga [model::bga::createBGA $rows $cols]

    # rebuild canvas
    controller::build

    # enable selection mode
    set ::model::mode "select"

    ui::status::set "Selection enabled"
}
    