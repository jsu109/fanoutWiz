proc controller::build {structureName} {

    set bga $controller::state::bga

    if {$bga eq ""} return

    set frame [model::fanout::createFanout $bga $structureName]

    set compiled [model::fanoutCompiler::compile $frame]
    set vias     [model::via::collectFromFanout $frame]

    set renderFrame [dict create \
        pads   [model::bga::generatePads $bga] \
        segs   $compiled \
        vias   $vias \
        bounds [model::bga::computeBounds $bga]]

    controller::render $renderFrame
}

proc controller::render {frame} {

    render::scene::draw $::render::canvas $frame

    ui::bindings::attachPadSelection $::render::canvas
}