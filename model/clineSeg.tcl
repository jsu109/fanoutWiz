namespace eval model::clineSeg {}

# segment {
#     id
#     width
#     length
#     angle
#     nodes {
#         from
#         to
#     }
#     geometry {
#         x1 y1
#         x2 y2
#     }
# }

proc model::clineSeg::createSeg {} {
    return [dict create \
    width 20 \
    length 100\
    angle 45\
    ]
}


proc model::clineSeg::generateSegs {segDef} {

    set segs {}

    set width  [dict get $segDef width]
    set length [dict get $segDef length]
    set angle  [dict get $segDef angle]

    # For now we assume origin at (0,0)
    set x1 0
    set y1 0

    # simple directional endpoint (angle in degrees)
    set rad [expr {$angle * acos(-1) / 180.0}]

    set x2 [expr {$x1 + $length * cos($rad)}]
    set y2 [expr {$y1 + $length * sin($rad)}]

    dict set segs seg1 id seg1

    dict set segs seg1 width $width
    dict set segs seg1 length $length
    dict set segs seg1 angle $angle

    dict set segs seg1 geometry x1 $x1
    dict set segs seg1 geometry y1 $y1
    dict set segs seg1 geometry x2 $x2
    dict set segs seg1 geometry y2 $y2

    dict set segs seg1 nodes from "n0"
    dict set segs seg1 nodes to   "n1"

    return $segs
}