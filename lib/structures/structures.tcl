package require fanout::model
source units/conversions.tcl
namespace eval fanout::structures {
    variable registry
}

set fanout::structures::registry(basic) [dict create \
    id basic \
    label "Basic two-segment escape" \
    policy [dict create \
        preferredSide auto \
        laneMode perColumn \
        ringPolicy row_depth \
        jogStrategy none \
        escapeUnusedPads no \
    ] \
    rules [dict create \
        clineWidth [units::mm 0.1] \
        clineSpacing [units::um 100] \
        neckLength [units::um 100] \
        lanePitch [units::um 400] \
        clearance [units::um 100] \
    ] \
    segments {neck escape} \
    pipeline [dict create \
        sideSelector  model::topology::selectSide \
        laneAllocator model::topology::selectLane \
        escapePlanner model::topology::orthogonalEscape \
    ] \
]

set fanout::structures::registry(dogbone) [dict replace \
    $fanout::structures::registry(basic) \
    id dogbone \
    label "Dogbone escape"]
