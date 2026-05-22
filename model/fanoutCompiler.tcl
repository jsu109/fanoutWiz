# * routing logic
# * escape calculations
# * via insertion
# * congestion analysis

namespace eval model::fanoutCompiler {}
proc model::fanoutCompiler::compile {fanout} {

    set segments {}

    set pads [dict get $fanout pads]

    foreach padId [dict keys $pads] {

        set p [dict get $pads $padId]

        set x [dict get $p position x]
        set y [dict get $p position y]

        set dir [dict get $p escape direction]

        # ---------------------------------------
        # SINGLE SEGMENT PER PAD
        # ---------------------------------------

        set length 1.0
        set width 1

        # direction vector (simple orthogonal escape)
        set dx 0
        set dy 0

        if {$dir eq "N"} { set dy $length }
        if {$dir eq "S"} { set dy [expr {-1 * $length}] }
        if {$dir eq "E"} { set dx $length }
        if {$dir eq "W"} { set dx [expr {-1 * $length}] }

        set x2 [expr {$x + $dx}]
        set y2 [expr {$y + $dy}]

        # build segment via clineSeg generator
        set segDef [dict create \
            width $width \
            length $length \
            angle 0 \
        ]

        set seg [model::clineSeg::generateSegs $segDef]

        # override geometry with REAL pad-based origin
        dict set seg seg1 geometry x1 $x
        dict set seg seg1 geometry y1 $y
        dict set seg seg1 geometry x2 $x2
        dict set seg seg1 geometry y2 $y2

        dict set seg seg1 nodes from "$padId"
        dict set seg seg1 nodes to   "$padId.exit"

        dict set segments $padId $seg seg1
    }

    return [dict create segments $segments]
}