# drawTrace
# drawVia
# drawEscapeChannel



namespace eval render::fanout {}

proc render::fanout::draw {canvas frame} {

    set pads [dict get $frame pads] 
    set segs [dict get $frame segs]

    render::pads::drawPads $canvas $pads $::model::bga
    render::clineSeg::drawClineSegs $canvas $segs $::model::clineSeg
}