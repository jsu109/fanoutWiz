proc controller::build {structureName} {

    set bga $::controller::state::bga

    if {$bga eq ""} {
        return
    }

    set fanoutFrame [model::fanout::createFanout $bga $structureName]
    set compiled [model::fanoutCompiler::compile $fanoutFrame]
    set vias [model::via::collectFromFanout $fanoutFrame]

    set pads [model::bga::generatePads $bga]
    set cols [dict get $bga cols]
    set rows [dict get $bga rows]
    set pitch [dict get $bga pitch]
    set padRadius [dict get $bga padRadius]

    set halfWidth [expr {(($cols - 1) * $pitch) / 2.0}]
    set halfHeight [expr {(($rows - 1) * $pitch) / 2.0}]

    set renderFrame [dict create \
        pads $pads \
        segs $compiled \
        vias $vias \
        worldW [expr {2 * ($halfWidth + $padRadius)}] \
        worldH [expr {2 * ($halfHeight + $padRadius)}]]

    set ::controller::lastFrame $renderFrame
    controller::render $renderFrame
}

proc controller::render {frame} {

    if {![info exists ::render::canvas] || ![winfo exists $::render::canvas]} {
        return
    }

    $::render::canvas delete all

    set ch [winfo height $::render::canvas]
    set cw [winfo width $::render::canvas]

    view::fit [dict get $frame worldW] [dict get $frame worldH] $cw $ch
    render::fanout::draw $::render::canvas $frame

    ui::bindings::attachPadSelection $::render::canvas
}