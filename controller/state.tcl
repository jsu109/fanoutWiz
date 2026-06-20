namespace eval controller {}
namespace eval controller::state {
    variable mode "edit"
    variable bga ""
    variable selectedPad ""
    variable structure "basic"
    variable escapePolicy "nearestEdge"
    variable viaPolicy "dogbone"

    variable data
    set data {}

}


proc controller::state::set {key value} {
    variable data
    dict set data $key $value
    puts "STATE: $key = $value"
}

proc controller::state::get {key} {
    variable data
    return [dict get $data $key]
}

