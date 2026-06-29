namespace eval controller {}
namespace eval controller::state {

    variable data
}

proc controller::state::createStructureConfig {{preset basic}} {
    ::set structure [model::topology::getStructure $preset]

    if {[dict exists $structure id]} {
        ::set preset [dict get $structure id]
    }

    dict set structure preset $preset
    dict set structure bga [dict create \
        rows 5 \
        cols 5 \
        pitch [units::mm 1] \
        ballDiameter [units::mm 0.5] \
        padScale 0.8 \
        defaultPadType circle]

    if {[dict exists $structure via]} {
        dict set structure vias active [dict get $structure via]
    } elseif {[info exists ::fanout::structures::viaTypes(through)]} {
        dict set structure via $::fanout::structures::viaTypes(through)
        dict set structure vias active $::fanout::structures::viaTypes(through)
    }

    return $structure
}

namespace eval controller::state {
    variable data
    # Application state
    set data [dict create \
        mode edit \
        structureConfig [controller::state::createStructureConfig basic] \
        selectedPad {} \
        structure {} \
        escapePolicy nearestEdge \
        viaPolicy dogbone \
    ]
}

namespace eval controller::binding {
    variable map
}
proc controller::binding::bind {key path} {
    variable map
    set map($key) $path
}

proc controller::state::set {key value} {
    variable data

    # check if key is bound
    if {[info exists ::controller::binding::map($key)]} {
        dict set data {*}[split $::controller::binding::map($key) "."] $value
        return $value
    }

    # fallback: direct top-level dict key
    if {[dict exists $data $key]} {
        dict set data $key $value
        return $value
    }

    dict set data $key $value
    return $value
}


proc controller::state::get {args} {
    variable data

    if {[llength $args] == 0} {
        error "controller::state::get requires at least one key"
    }

    # hierarchical access (preferred)
    if {[dict exists $data {*}$args]} {
        return [dict get $data {*}$args]
    }

    # single-key fallback
    if {[llength $args] == 1} {
        return ""
    }

    return ""
}

proc controller::state::exists {args} {
    variable data
    # value does not exist
    if {[catch {dict get $data {*}$args} value]} {
        return 0
    }
    # values is set as an empty string
    if {$value eq "" } {
        return 0
    }

    return 1
}

proc controller::state::unset {args} {
    variable data
    dict unset data {*}$args
}

proc controller::state::dump {} {
    variable data
    return $data
}
