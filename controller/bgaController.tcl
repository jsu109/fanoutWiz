namespace eval controller {}

proc controller::updateStructureConfig {args} {
    if {[llength $args] < 2} {
        error "controller::updateStructureConfig requires a path and value"
    }

    set value [lindex $args end]
    set path [lrange $args 0 end-1]
    set config [controller::state::get structureConfig]
    dict set config {*}$path $value
    controller::state::set structureConfig $config
    return $config
}

proc controller::setStructurePreset {structureName} {
    set preset [string tolower $structureName]
    set current [controller::state::get structureConfig]
    set config [controller::state::createStructureConfig $preset]

    foreach section {bga rules policy spacing clineSeg vias} {
        if {[dict exists $current $section]} {
            dict set config $section [dict get $current $section]
        }
    }

    if {[info exists ::controller::binding::map]} {
        foreach key [array names ::controller::binding::map] {
            set path [split $::controller::binding::map($key) "."]
            if {[dict exists $current {*}$path]} {
                dict set config {*}$path [dict get $current {*}$path]
            }
        }
    }

    controller::state::set structureConfig $config
    return $config
}

proc controller::buildStructure {} {
    set structure [model::structure::createStructure \
        [controller::state::get structureConfig]]
    controller::state::set structure $structure
    return $structure
}

proc controller::collectFrame {} {
    if {![controller::state::exists structure]} {
        error "Cannot collect render frame before building a structure"
    }

    set structure [controller::state::get structure]
    set bga [dict get $structure bga]
    set pads [dict get $structure pads]
    set fanout [dict get $structure fanout]
    
    set segs [model::fanoutCompiler::compile $fanout]
    set vias [dict get $structure vias]
    
    set features {}
    lappend features {*}[model::measure::normalisePads $pads]
    lappend features {*}[model::measure::normaliseSegments $segs]
    lappend features {*}[model::measure::normaliseVias $vias]

    set featureIndex {}
    foreach f $features {
        dict set featureIndex [dict get $f id] $f
    }

    set cols [dict get $bga cols]
    set rows [dict get $bga rows]
    set pitch [dict get $bga pitch]
    set padRadius [dict get $bga padRadius]

    set halfWidth  [expr {(($cols - 1) * $pitch) / 2.0}]
    set halfHeight [expr {(($rows - 1) * $pitch) / 2.0}]

    set worldW [expr {2 * ($halfWidth + $padRadius)}]
    set worldH [expr {2 * ($halfHeight + $padRadius)}]

    return [dict create \
        bga $bga \
        pads $pads \
        segs $segs \
        vias $vias \
        featureIndex $featureIndex \
        worldW $worldW \
        worldH $worldH]
}

proc controller::build {{structureName {}}} {
    if {$structureName ne ""} {
        set currentPreset [controller::state::get structureConfig preset]
        if {$currentPreset ne [string tolower $structureName]} {
            controller::setStructurePreset $structureName
        }
    }
    puts "necklength: [controller::state::get structureConfig rules neckLength]"
    $::render::canvas delete all
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
    controller::buildStructure
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

    if {[winfo exists .root.sidebar.inner.diagnostics.result]} {
        if {$passed} {
            .root.sidebar.inner.diagnostics.result configure \
                -text "PASS  $summary" \
                -fg "#8bd450"
        } else {
            .root.sidebar.inner.diagnostics.result configure \
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
    set structureName basic
    if {[info exists ::ui::window::structurePreset]} {
        set structureName [string tolower $::ui::window::structurePreset]
    }
    if {[controller::state::get structureConfig preset] ne $structureName} {
        controller::setStructurePreset $structureName
    }

    if {[info exists ::fanout::structures::registry($structureName)]} {
        controller::updateStructureConfig policy \
            [ui::window::collectSectionParamOverrides policy]
    }

    if {[info exists ::ui::window::viaStructurePreset]} {
        set viaName [string tolower $::ui::window::viaStructurePreset]
        if {[info exists ::fanout::structures::viaTypes($viaName)]} {
            controller::updateStructureConfig vias active \
                $::fanout::structures::viaTypes($viaName)
        }
    }

    controller::tools::setActiveTool
    set tool $::controller::activeTool

    ui::status::set "Selection enabled"
    controller::buildStructure
    controller::build
}
