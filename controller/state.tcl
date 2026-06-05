namespace eval controller {}
namespace eval controller::state {}

set controller::state::mode "edit"
set controller::state::bga ""
set controller::state::selectedPad ""
set controller::state::structure "basic"
set controller::state::escapePolicy "nearestEdge"
set controller::state::viaPolicy "dogbone"