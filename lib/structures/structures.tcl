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
        viaInPad no \
        escapePolicy nearestEdge \
    ] \
    rules [dict create \
        traceWidth [units::mm 0.35] \
        traceSpacing [units::mm 0.1] \
        clearance [units::mm 0.1] \
        neckLength [units::um 100] \
    ] \
    spacing [dict create \
        lineToLineSpacing [units::mm 0.1] \
        lineToPadSpacing [units::mm 0.1] \
        lineToViaSpacing [units::mm 0.1] \
        \
        viaToViaSpacing [units::mm 0.1]\
        viaToPadSpacing [units::mm 0.2]\
        ]\
    clineSeg [dict create \
        lineWidth [units::mm 0.1] \
        ]\
    via [dict create \
        type through \
        holeDiameter [units::mm 0.1] \
        annularRing [units::mm 0.125] \
    ] \
    segments {neck escape} \
    pipeline [dict create \
        sideSelector  model::topology::selectSide \
        laneAllocator model::topology::selectLane \
        escapePlanner model::topology::orthogonalEscape \
    ] \
]


set fanout::structures::registry(dogbone) [dict create \
    id dogbone \
    label "dogbone" \
    policy [dict create \
        preferredSide auto \
        laneMode perColumn \
        ringPolicy row_depth \
        jogStrategy none \
        escapeUnusedPads no \
        viasOnOuterPads no \
        viaInPad no \
        escapePolicy quadrant \
    ] \
    rules [dict create \
        traceWidth [units::mm 0.1] \
        traceSpacing [units::mm 0.1] \
        clearance [units::mm 0.1] \
        neckLength [units::um 100] \
    ] \
    spacing [dict create \
        lineToLineSpacing [units::mm 0.1] \
        lineToPadSpacing [units::mm 0.1] \
        lineToViaSpacing [units::mm 0.1] \
        \
        viaToViaSpacing [units::mm 0.1]\
        viaToPadSpacing [units::mm 0.2]\
        ]\
    clineSeg [dict create \
        lineWidth [units::mm 0.1] \
        ]\
    via [dict create \
        type through \
        holeDiameter [units::mm 0.1] \
        annularRing [units::mm 0.125] \
    ] \
    segments {neck escape} \
    pipeline [dict create \
        sideSelector  model::topology::selectSide \
        laneAllocator model::topology::selectLane \
        escapePlanner model::topology::quadrantEscape \
    ] \
]



