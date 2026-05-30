package require tcltest

namespace import ::tcltest::*

set testDir [file dirname [file normalize [info script]]]
set repoRoot [file dirname $testDir]

lappend auto_path [file join $repoRoot lib]
source [file join $repoRoot units conversions.tcl]
package require fanout::model
source [file join $repoRoot lib structures structures.tcl]
source [file join $repoRoot lib render clineSeg.tcl]

proc makeCompiledFanout {rows cols} {
    set bga [model::bga::createBGA $rows $cols]
    set fanout [model::fanout::createFanout $bga basic]

    return [dict create \
        bga $bga \
        pads [model::bga::generatePads $bga] \
        compiled [model::fanoutCompiler::compile $fanout] \
    ]
}

test fanout-ir-1.1 {compiler emits one padClines entry per pad} -body {
    set fixture [makeCompiledFanout 5 5]

    list \
        [llength [dict keys [dict get $fixture pads]]] \
        [llength [dict keys [dict get $fixture compiled]]]
} -result {25 25}

test fanout-ir-1.2 {fanout records selected structure and BGA dimensions} -body {
    set bga [model::bga::createBGA 3 4]
    set fanout [model::fanout::createFanout $bga basic]

    list \
        [dict get $fanout structure] \
        [dict get $fanout bga rows] \
        [dict get $fanout bga cols] \
        [dict get $fanout bga pitch]
} -result {basic 3 4 1000.0}

test fanout-ir-1.3 {compiler emits strict neck and escape segments per pad} -body {
    set fixture [makeCompiledFanout 3 4]
    set compiled [dict get $fixture compiled]
    set segmentCount 0

    foreach padId [dict keys $compiled] {
        set padClines [dict get $compiled $padId]
        if {[lsort [dict keys $padClines]] ne {meta segments}} {
            error "bad padClines keys for $padId: [dict keys $padClines]"
        }

        set segments [dict get $padClines segments]
        if {[lsort [dict keys $segments]] ne {escape neck}} {
            error "bad segment keys for $padId: [dict keys $segments]"
        }

        foreach segName {neck escape} {
            set segment [dict get $segments $segName]
            set keys [lsort [dict keys $segment]]
            if {$keys ne {angle geometry id laneId nodes side width}} {
                error "bad $segName keys for $padId: $keys"
            }
            incr segmentCount
        }
    }

    set segmentCount
} -result 24

test fanout-ir-1.4 {compiled segment geometry is non-zero length} -body {
    set fixture [makeCompiledFanout 3 3]
    set compiled [dict get $fixture compiled]
    set zeroLength {}

    foreach padId [dict keys $compiled] {
        foreach segName {neck escape} {
            set geom [dict get $compiled $padId segments $segName geometry]
            set x1 [dict get $geom x1]
            set y1 [dict get $geom y1]
            set x2 [dict get $geom x2]
            set y2 [dict get $geom y2]

            if {$x1 == $x2 && $y1 == $y2} {
                lappend zeroLength [list $padId $segName]
            }
        }
    }

    set zeroLength
} -result {}

test fanout-ir-1.5 {compiler rejects padClines missing lane metadata} -body {
    set badFanout [dict create pads [dict create A1 [dict create clines [dict create \
        meta [dict create padId A1 side N] \
        segments [dict create \
            neck [dict create x1 0 y1 0 x2 0 y2 1] \
            escape [dict create x1 0 y1 1 x2 1 y2 1]]]]]]

    model::fanoutCompiler::compile $badFanout
} -returnCodes error -match glob -result {*missing required key: laneId}

test lane-assignment-1.1 {basic topology escapes toward nearest BGA edge} -body {
    set fixture [makeCompiledFanout 3 3]
    set compiled [dict get $fixture compiled]
    set actual {}

    foreach padId {A1 A2 A3 B1 B2 B3 C1 C2 C3} {
        lappend actual [list \
            $padId \
            [dict get $compiled $padId meta side] \
            [dict get $compiled $padId meta laneId] \
        ]
    }

    set actual
} -result {{A1 N 0} {A2 N 0} {A3 N 0} {B1 W 0} {B2 N 1} {B3 E 0} {C1 W 0} {C2 S 0} {C3 E 0}}

test lane-assignment-1.2 {escape geometry moves outward from selected side} -body {
    set fixture [makeCompiledFanout 3 3]
    set compiled [dict get $fixture compiled]
    set failures {}

    foreach padId [dict keys $compiled] {
        set side [dict get $compiled $padId meta side]
        set geom [dict get $compiled $padId segments escape geometry]
        set x1 [dict get $geom x1]
        set y1 [dict get $geom y1]
        set x2 [dict get $geom x2]
        set y2 [dict get $geom y2]

        switch -- $side {
            N {
                set ok [expr {$x1 == $x2 && $y2 < $y1}]
            }
            S {
                set ok [expr {$x1 == $x2 && $y2 > $y1}]
            }
            E {
                set ok [expr {$y1 == $y2 && $x2 > $x1}]
            }
            W {
                set ok [expr {$y1 == $y2 && $x2 < $x1}]
            }
            default {
                set ok 0
            }
        }

        if {!$ok} {
            lappend failures [list $padId $side $geom]
        }
    }

    set failures
} -result {}

test render-1.1 {renderer creates one line per compiled segment} -body {
    set fixture [makeCompiledFanout 5 5]
    set ::testLineCount 0
    set ::testBadTagCount 0

    proc testCanvas {args} {
        if {[lrange $args 0 1] ne {create line}} {
            error "unexpected canvas call: $args"
        }

        set tagsIndex [lsearch -exact $args -tags]
        if {$tagsIndex < 0 || [lsearch -exact [lindex $args [expr {$tagsIndex + 1}]] cline] < 0} {
            incr ::testBadTagCount
        }

        incr ::testLineCount
    }

    set frame [dict create segs [dict get $fixture compiled]]
    render::clineSeg::drawClineSegs testCanvas $frame
    rename testCanvas {}

    set result [list $::testLineCount $::testBadTagCount]
    unset ::testLineCount
    unset ::testBadTagCount
    set result
} -result {50 0}

cleanupTests
