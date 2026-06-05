namespace eval controller {}

proc controller::dispatch {event args} {
    switch -- $event {

        MODE_CHANGED {
            controller::onModeChanged {*}$args
        }

        BGA_CHANGED {
            controller::onBGAChanged {*}$args
        }

        PAD_SELECTED {
            controller::onPadSelected {*}$args
        }

        STRUCTURE_CHANGED {
            controller::onStructureChanged {*}$args
        }

        ESCAPE_POLICY_CHANGED {
            controller::onEscapePolicyChanged {*}$args
        }

        BUILD {
            controller::build {*}$args
        }

        default {
            error "Unknown event: $event"
        }
    }
}

proc controller::onModeChanged {mode} {
    set ::controller::state::mode $mode
    ui::sidebar::setMode $mode
}


proc controller::onBGAChanged {rows cols} {

    set ::controller::state::bga \
        [model::bga::createBGA $rows $cols]

    controller::dispatch BUILD basic
}

proc controller::onStructureChanged {structure} {
    set ::controller::state::structure $structure
    controller::dispatch BUILD $structure
}

proc controller::onPadSelected {padName} {

    set ::controller::state::selectedPad $padName

    ui::status::set "Selected pad: $padName"

    render::scene::highlightPad $padName
}