namespace eval model::clineSeg {}

# segment {
#     id
#     type
#     width
#     length
#     angle
#     laneId
#     side
#     nodes {
#         from
#         to
#     }
#     geometry {  ;# generated segment geometry
#         x1 y1
#         x2 y2
#     }
# }

proc model::clineSeg::createSeg {} {
    return [dict create \
    width [units::mm 0.1] \
    length [units::mm 1]\
    angle 45\
    ]
}

proc model::clineSeg::resolveStructureName {structureName} {
    if {[info exists ::fanout::structures::registry($structureName)]} {
        return $structureName
    }

    return basic
}

proc model::clineSeg::definitionFromStructure {structureName} {
    set structureName [model::clineSeg::resolveStructureName $structureName]
    set structure [model::topology::getStructure $structureName]

    if {![dict exists $structure via]} {
        error "Structure [dict get $structure id] missing via definition"
    }
    set segDef [dict get $structure clineSeg]

    return $segDef
}
proc model::clineSeg::generateSegs {segDef start} {

    set segs {}

    set width  [dict get $segDef width]
    set length [dict get $segDef length]
    set angle  [dict get $segDef angle]
    set layer 1
    set x1 [dict get $start x]
    set y1 [dict get $start y]

    set rad [expr {$angle * acos(-1) / 180.0}]

    set x2 [expr {$x1 + $length * cos($rad)}]
    set y2 [expr {$y1 + $length * sin($rad)}]

    dict set segs  id seg1
    dict set segs  type cline
    dict set segs  width $width
    dict set segs  length $length
    dict set segs  angle $angle
    dict set segs  layer $layer
    # dict set segs seg1 geometry x1 $x1
    # dict set segs seg1 geometry y1 $y1
    # dict set segs seg1 geometry x2 $x2
    # dict set segs seg1 geometry y2 $y2

    # dict set segs seg1 nodes from n0
    # dict set segs seg1 nodes to n1

    return $segs
}
