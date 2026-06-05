package require fanout::model
source units/conversions.tcl
namespace eval fanout::structures {
    variable registry
    variable viaTypes
}
# fanout::structures::viaTypes is a dict of via types, each containing:
# - id: unique identifier for the via type
# - label: human-readable name for the via type
# - rules: dict of design rules for the via type (hole diameter, annular ring, etc.)
set fanout::structures::viaTypes(through) [dict create \
    id through \
    type "Through" \
    rules [dict create \
        holeDiameter [units::mm 0.1] \
        annularRing [units::mm 0.125] \
    ] \
]

set fanout::structures::viaTypes(blind) [dict create \
    id blind \
    type "Blind" \
    rules [dict create \
        holeDiameter [units::mm 0.1] \
        annularRing [units::mm 0.125] \
    ] \
]

# fanout::structures::registry is a dict of structure presets, each containing:
# - id: unique identifier for the preset
# - label: human-readable name for the preset
# - policy: dict of policies governing the escape strategy
# - rules: dict of design rules (trace width, spacing, etc.)
# - spacing: dict of spacing rules between different elements   

set fanout::structures::registry(basic) [dict create \
    id basic \
    label "Basic two-segment escape" \
    policy [dict create \
        preferredSide auto \
        laneMode perColumn \
        ringPolicy row_depth \
        jogStrategy none \
        escapeUnusedPads no \
        viasOnOuterPads yes \
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
    via $::fanout::structures::viaTypes(through) \
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
    via $::fanout::structures::viaTypes(blind) \
    segments {neck escape} \
    pipeline [dict create \
        sideSelector  model::topology::selectSide \
        laneAllocator model::topology::selectLane \
        escapePlanner model::topology::quadrantEscape \
    ] \
]




