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
