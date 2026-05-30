namespace eval controller {}

proc controller::setMode {mode} {

    set ::model::mode $mode

    if {![winfo exists .root.sidebar.geometry.rows.slider]} {
        return
    }

    if {$mode eq "select"} {

        .root.sidebar.geometry.rows.slider configure -state disabled
        .root.sidebar.geometry.cols.slider configure -state disabled

        .root.sidebar.modeValue configure -text "SELECT"

    } else {

        .root.sidebar.geometry.rows.slider configure -state normal
        .root.sidebar.geometry.cols.slider configure -state normal

        .root.sidebar.modeValue configure -text "EDIT"
    }
}
proc controller::toggleMode {} {

    if {$::model::mode eq "edit"} {

        controller::applyAndEnableSelection

        .root.sidebar.modeToggle configure -text "Switch to EDIT"

    } else {

        controller::setMode edit

        .root.sidebar.modeToggle configure -text "Switch to SELECT"

    }

}

proc controller::isEditMode {} {
    return [expr {$::model::mode eq "edit"}]
}

proc controller::applyBGA {} {

    if {![controller::isEditMode]} {
        return
    }
    set rows [expr {int([.root.sidebar.geometry.rows.slider get])}]
    set cols [expr {int([.root.sidebar.geometry.cols.slider get])}]

    set ::model::bga [model::bga::createBGA $rows $cols]
    
    controller::build
}
proc controller::collectFrame {} {

    set bga $::model::bga
    set seg $::model::clineSeg

    set pads [model::bga::generatePads $bga]
    set fanout [model::fanout::createFanout $bga basic] 

    set segs [model::fanoutCompiler::compile $fanout]
    set vias [model::via::collectFromFanout $fanout]
    set cols [dict get $bga cols]
    set rows [dict get $bga rows]
    set pitch [dict get $bga pitch]
    set padRadius [dict get $bga padRadius]

    set halfWidth  [expr {(($cols - 1) * $pitch) / 2.0}]
    set halfHeight [expr {(($rows - 1) * $pitch) / 2.0}]

    set worldW [expr {2 * ($halfWidth + $padRadius)}]
    set worldH [expr {2 * ($halfHeight + $padRadius)}]

    return [dict create \
        pads $pads \
        segs $segs \
        vias $vias \
        worldW $worldW \
        worldH $worldH]
}

proc controller::build {} {

    $::render::canvas delete all

    # Single source of truth for renderable scene bounds
    set frame [controller::collectFrame]
    set ::controller::lastFrame $frame
    set ch [winfo height $::render::canvas]
    set cw [winfo width $::render::canvas]
    set worldW [dict get $frame worldW]
    set worldH [dict get $frame worldH]

    view::fit $worldW $worldH $cw $ch

    render::fanout::draw $::render::canvas $frame
    
    
    ui::bindings::attachPadSelection $::render::canvas
}

proc controller::countCompiledSegments {segs} {
    set count 0

    dict for {padId padClines} $segs {
        incr count [llength [dict keys [dict get $padClines segments]]]
    }

    return $count
}

proc controller::countCanvasItemsByTagAndType {canvas tag itemType} {
    set count 0

    foreach item [$canvas find withtag $tag] {
        if {[$canvas type $item] eq $itemType} {
            incr count
        }
    }

    return $count
}

proc controller::validateRenderedClines {canvas} {
    set invalid {}

    foreach item [$canvas find withtag cline] {
        if {[$canvas type $item] ne "line"} {
            lappend invalid $item
            continue
        }

        set coords [$canvas coords $item]
        if {[llength $coords] != 4} {
            lappend invalid $item
            continue
        }

        lassign $coords x1 y1 x2 y2
        if {$x1 == $x2 && $y1 == $y2} {
            lappend invalid $item
            continue
        }
    }

    return $invalid
}

proc controller::runRenderDiagnostics {} {
    controller::build

    set frame $::controller::lastFrame
    set expectedPads [llength [dict keys [dict get $frame pads]]]
    set expectedClines [controller::countCompiledSegments [dict get $frame segs]]

    set actualPads [llength [$::render::canvas find withtag pad]]
    set actualClines [controller::countCanvasItemsByTagAndType $::render::canvas cline line]
    set invalidClines [controller::validateRenderedClines $::render::canvas]

    set passed [expr {
        $expectedPads == $actualPads &&
        $expectedClines == $actualClines &&
        [llength $invalidClines] == 0
    }]

    set summary [format "Pads %d/%d | Clines %d/%d | Invalid %d" \
        $actualPads $expectedPads \
        $actualClines $expectedClines \
        [llength $invalidClines]]

    if {[winfo exists .root.sidebar.diagnostics.result]} {
        if {$passed} {
            .root.sidebar.diagnostics.result configure \
                -text "PASS  $summary" \
                -fg "#8bd450"
        } else {
            .root.sidebar.diagnostics.result configure \
                -text "FAIL  $summary" \
                -fg "#ff6b6b"
        }
    }

    if {$passed} {
        ui::status::set "Render diagnostics passed: $summary"
    } else {
        ui::status::set "Render diagnostics failed: $summary"
    }

    return [dict create \
        passed $passed \
        expectedPads $expectedPads \
        actualPads $actualPads \
        expectedClines $expectedClines \
        actualClines $actualClines \
        invalidClines $invalidClines]
}

proc controller::applyAndEnableSelection {} {
    set rows [expr {int([.root.sidebar.geometry.rows.slider get])}]
    set cols [expr {int([.root.sidebar.geometry.cols.slider get])}]

    set ::model::bga [model::bga::createBGA $rows $cols]

    

    # controller::setMode select

    ui::status::set "Selection enabled"
    controller::build
}
