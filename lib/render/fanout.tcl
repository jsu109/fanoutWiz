# drawTrace
# drawVia
# drawEscapeChannel



namespace eval render::fanout {}

proc render::fanout::draw {canvas frame} {

    set pads [dict get $frame pads] 
    
    render::pads::drawPads $canvas $pads $::model::bga
    render::clineSeg::drawClineSegs $canvas $frame
    render::via::drawVias $canvas $frame
    
}