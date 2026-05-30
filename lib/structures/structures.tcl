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
        viasOnOuterPads no \
    ] \
    rules [dict create \
        traceWidth [units::mil 5] \
        traceSpacing [units::mil 6] \
        clearance [units::mil 6] \
        neckLength [units::um 100] \
    ] \
    via [dict create \
        type through \
        holeDiameter [units::mil 8] \
        annularRing [units::mil 6] \
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
