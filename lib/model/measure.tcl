namespace eval model::measure {}

# feature {
#     type pad|segment|via
#     id   C3|neck|via12
#     ref  <original object>
# }

proc model::measure::normalisePads {pads} {

    return [lmap padId [dict keys $pads] {
        set pad [dict get $pads $padId]
        dict create \
            type pad \
            id "${padId}.pad" \
            ref $pad
    }]
}
proc model::measure::normaliseSegments {segs} {

    return [lmap segId [dict keys $segs] {
        set seg [dict get $segs $segId]

        dict create \
            type segment \
            id "${segId}.segment" \
            ref $seg
    }]
}
proc model::measure::normaliseVias {vias} {
    return [lmap viaId [dict keys $vias] {
        set via [dict get $vias $viaId]
        dict create \
            type via \
            id "${viaId}.via" \
            ref $via
    }]
}

proc model::measure::resolveFeature {feature} {
    
    set type [dict get $feature type]
    set ref  [dict get $feature ref]

    switch $type {

        pad {
            return [dict create \
                x [dict get $ref x] \
                y [dict get $ref y]]
        }

        segment {
            # currently only supports clineSeg neck segments, but could be extended to support other types of segments eg escape. todo i will get a bug if i try to resolve an escape segment as it doesn't have the same geometry keys as the neck segment
            set geom [dict get $ref segments neck geometry]

            set x1 [dict get $geom x1]
            set y1 [dict get $geom y1]
            set x2 [dict get $geom x2]
            set y2 [dict get $geom y2]
            # return midpoint for now, but could be extended to return other points of interest (e.g. escape exit)
            return [dict create \
                x [expr {($x1 + $x2) / 2.0}] \
                y [expr {($y1 + $y2) / 2.0}]]
        }

        via {
            set geom [dict get $ref geometry]
            return [dict create \
                x [dict get $geom x] \
                y [dict get $geom y]]
        }
    }
}

proc model::measure::manhattanDistance {feature1 feature2} {
    set pos1 [model::measure::resolveFeature $feature1]
    set pos2 [model::measure::resolveFeature $feature2]
    puts "Resolved positions: $pos1, $pos2"
    set dx [expr {abs([dict get $pos1 x] - [dict get $pos2 x])}]
    set dy [expr {abs([dict get $pos1 y] - [dict get $pos2 y])}]

    return [expr {$dx + $dy}]
}
proc model::measure::euclideanDistance {feature1 feature2} {
    set pos1 [model::measure::resolveFeature $feature1]
    set pos2 [model::measure::resolveFeature $feature2]
    puts "Resolved positions: $pos1, $pos2"
    set dx [expr {[dict get $pos1 x] - [dict get $pos2 x]}]
    set dy [expr {[dict get $pos1 y] - [dict get $pos2 y]}]
    

    return [expr {sqrt($dx*$dx + $dy*$dy)}]
}