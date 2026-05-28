package require fanout::model
source units/conversions.tcl
namespace eval fanout::structures {
    variable registry
}

set fanout::structures::registry(dogbone) [dict create \
    policy [dict create \
        preferredSide auto \
        laneMode perColumn \
        ringPolicy outer_first \
        jogStrategy stagger \
        escapeUnusedPads no \
    ] \
    rules [dict create \
        neckLength [units::um 100] \
        lanePitch [units::um 400] \
        clearance [units::um 100] \
    ] \
    pipeline [dict create \
        sideSelector  model::topology::selectSide \
        laneAllocator model::topology::columnLane \
        escapePlanner model::topology::orthogonalEscape \
    ] \
]