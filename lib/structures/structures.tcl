
package  require fanout::model
namespace eval fanout::structures {
    variable registry
}
set fanout::structures::registry(dogbone) {
    
    policy {
        preferredSide auto
        laneMode perColumn
        ringPolicy outer_first
        jogStrategy stagger
        escapeUnusedPads no
    }

    parameters {
        # should we get this info based on the bga.
        # neckLength 200 
        # lanePitch 100
        # clearance 50
    }

    pipeline {
        sideSelector    model::topology::selectSide
        laneAllocator   model::topology::columnLane
        escapePlanner   model::topology::orthogonalEscape
    }
}