namespace eval ui::window {
    variable toolHeaderOverviewFrame
    variable modeValue
    variable modeHint
    variable modeToggle
}

proc ui::window::createSection {parent name title} {
    set frame [ui::canvas::widget $parent frame $name \
        -bg "#2a2d31" \
        -highlightbackground "#3b3f46" \
        -highlightthickness 1]
    pack $frame -fill x -padx 14 -pady {0 12}
    set titleWidget [ui::canvas::widget $frame label title \
        -text $title \
        -bg "#2a2d31" \
        -fg white \
        -font {Helvetica 11 bold}]
    pack $titleWidget -anchor w -padx 12 -pady {10 8}
    return $frame
}
proc ui::window::createActiveText {parent name text args} {
    set label [ui::canvas::widget $parent label $name \
        -text $text \
        -bg "#2a2d31" \
        -fg "#4cc2ff" \
        -font {Helvetica 12 bold}]

    pack $label -anchor w -padx 12

    # store reference for updates
    set ::ui::window::activeText($name) $label

    return $label
}
proc ui::window::setActiveText {name text} {
    if {[info exists ::ui::window::activeText($name)]} {
        $::ui::window::activeText($name) configure -text $text
    }
}
proc ui::window::createEntryControl {parent name labelText initial} {
    set controlFrame [ui::canvas::widget $parent frame $name -bg "#2a2d31"]
    pack $controlFrame -fill x -padx 12 -pady 6

    set label [ui::canvas::widget $controlFrame label label \
        -text $labelText \
        -bg "#2a2d31" \
        -fg "#cccccc"]
    pack $label -side left

    set varName ::ui::window::entry_$name
    set $varName $initial

    set entry [ui::canvas::widget $controlFrame entry entry \
        -textvariable $varName \
        -width 10]

    pack $entry -side right

    bind $entry <Return> [list ui::window::onEntryChanged $name $varName]
    bind $entry <FocusOut> [list ui::window::onEntryChanged $name $varName]

    return $entry
}
proc ui::window::onEntryChanged {key variableName} {
    controller::state::set $key [set $variableName]
}
proc ui::window::createSliderControl {parent name labelText from to initial res} {
    set initial [ui::window::sliderInitialValue $name $initial]

    set controlFrame [ui::canvas::widget $parent frame $name -bg "#2a2d31"]
    pack $controlFrame -fill x -padx 12 -pady 6

    # label is ONLY static text (optional, not value display)
    set label [ui::canvas::widget $controlFrame label label \
        -text $labelText \
        -bg "#2a2d31" \
        -fg "#cccccc"]

    pack $label -side left

    # slider is the only dynamic element
    set slider [ui::canvas::widget $controlFrame scale slider \
        -from $from \
        -to $to \
        -resolution $res \
        -orient horizontal \
        -showvalue 1 \
        -length 180 \
        -bg "#2a2d31" \
        -fg white \
        -troughcolor "#3c3c3c" \
        -activebackground "#4cc2ff" \
        -highlightthickness 0 \
        -borderwidth 0]

    $slider set $initial
    $slider configure -command [list ui::window::onSliderChanged $name]

    pack $slider -side right -fill x -expand 1

    return $slider
}

proc ui::window::sliderInitialValue {name fallback} {
    if {[info commands ::controller::state::get] eq ""} {
        return $fallback
    }

    switch -- $name {
        rows {
            set value [::controller::state::get structureConfig bga rows]
        }
        cols {
            set value [::controller::state::get structureConfig bga cols]
        }
        width {
            set value [::controller::state::get structureConfig rules traceWidth]
            if {$value ne ""} {
                set value [units::toMm $value]
            }
        }
        length {
            set value [::controller::state::get structureConfig rules neckLength]
            if {$value ne ""} {
                set value [units::toMm $value]
            }
        }
        pitch {
            
            if {$value ne ""} {
                set value [units::mm $value]
                set value [::controller::state::get structureConfig bga pitch]
            }
        }
        default {
            set value ""
        }
    }

    if {$value eq ""} {
        return $fallback
    }

    return $value
}

proc ui::window::onSliderChanged {args} {
    set key   [lindex $args 0]
    set value [lindex $args end]
    if {$key in {width length}} {
        set value [units::mm $value]
    }
    controller::state::set $key $value
}

proc ui::window::createComboControl {parent name labelText values textVariable} {
    set controlFrame [ui::canvas::widget $parent frame $name -bg "#2a2d31"]
    pack $controlFrame -fill x -padx 12 -pady {0 10}

    set label [ui::canvas::widget $controlFrame label label \
        -text $labelText -bg "#2a2d31" -fg "#cccccc"]
    pack $label -anchor w

    set combo [ui::canvas::widget $controlFrame combobox combo \
        -values $values -state readonly -textvariable $textVariable]
    pack $combo -fill x -pady {4 0}

    return [dict create frame $controlFrame label $label combo $combo]
}

proc ui::window::createActionButton {parent name text command} {
    set button [ui::canvas::widget $parent button $name \
        -text $text \
        -bg "#2f78c7" \
        -fg "#eff6ff" \
        -activebackground "#3d8df0" \
        -activeforeground "#ffffff" \
        -relief flat \
        -borderwidth 0 \
        -padx 10 \
        -pady 10 \
        -command $command]
    pack $button -fill x -padx 12 -pady {0 8}
    return $button
}


proc ui::window::buildControls {parent definitions} {
    set created [dict create]
    foreach definition $definitions {
        set type [lindex $definition 0]
        switch -- $type {
            slider {
                lassign $definition _ name label from to initial res
                dict set created $name [ui::window::createSliderControl $parent $name $label $from $to $initial $res]
            }
            combo {
                lassign $definition _ name label values variableName
                dict set created $name [ui::window::createComboControl $parent $name $label $values $variableName]
            }
            button {
                lassign $definition _ name text command
                dict set created $name [ui::window::createActionButton $parent $name $text $command]
            }
            entry {
            lassign $definition _ name label initial
            dict set created $name [ui::window::createEntryControl $parent $name $label $initial]
        }
        }
    }
    return $created
}



proc ui::window::collectSectionParamOverrides {sectionName} {
    set overrides [dict create]
    set prefix "::ui::window::${sectionName}_"
    foreach var [info vars ${prefix}*] {
        set key [string range $var [string length $prefix] end]
        set value [set $var]
        dict set overrides $key [expr {$value ? yes : no}]
    }
    return $overrides
    
}

proc ui::window::onSectionFlagChanged {sectionName key varName} {
    set value [expr {[set $varName] ? "yes" : "no"}]
    controller::updateStructureConfig $sectionName $key $value
}

proc ui::window::applySectionParamOverrides {structureName sectionName} {

    if {![info exists ::fanout::structures::registry($structureName)]} {
        return
    }
    
    set structure [model::topology::getStructure $structureName]
    set section [dict get $structure $sectionName]
    set overrides [ui::window::collectSectionParamOverrides $sectionName]
    dict for {key value} $overrides {
        if {[dict exists $section $key]} {
            dict set section $key $value
        }
    }

    dict set structure $sectionName $section
    set ::fanout::structures::registry($structureName) $structure
}

proc ui::window::refreshSectionParamOverrideControls {parent structureName sectionName} {
    if {[winfo exists $parent.${sectionName}List]} {
        destroy $parent.${sectionName}List
    }

    frame $parent.${sectionName}List -bg "#2a2d31"
    pack $parent.${sectionName}List -fill x -padx 12 -pady {0 8}

    if {![info exists ::fanout::structures::registry($structureName)]} {
        set structureName basic
    }

    set structure [model::topology::getStructure $structureName]
    set section [dict get $structure $sectionName]

    if {[info commands controller::state::get] ne ""} {
        set config [controller::state::get structureConfig]
        if {[dict exists $config preset] &&
            [string equal -nocase [dict get $config preset] $structureName] &&
            [dict exists $config $sectionName]} {
            set section [dict get $config $sectionName]
        }
    }

    set count 0
    dict for {key value} $section {
        if {![string equal -nocase $value yes] &&
            ![string equal -nocase $value true] &&
            ![string equal -nocase $value on] &&
            ![string equal $value 1] &&
            ![string equal -nocase $value no] &&
            ![string equal -nocase $value false] &&
            ![string equal -nocase $value off] &&
            ![string equal $value 0]} {
            continue
        }

        set varName "::ui::window::${sectionName}_${key}"
        if {[string equal -nocase $value yes] ||
            [string equal -nocase $value true] ||
            [string equal -nocase $value on] ||
            [string equal $value 1]} {
            set $varName 1
        } else {
            set $varName 0
        }

        set checkbox [ui::canvas::widget $parent.${sectionName}List checkbutton policy_$key \
            -text [string map {_ { }} $key] \
            -variable $varName \
            -command [list ui::window::onSectionFlagChanged $sectionName $key $varName]]
        pack $checkbox -anchor w -pady 1
        incr count
    }

    if {$count == 0} {
        set emptyLabel [ui::canvas::widget $parent.${sectionName}List label emptyLabel \
            -text "No boolean policy flags available for this preset." \
            -bg "#2a2d31" \
            -fg "#c7d0db"]
        pack $emptyLabel -anchor w -pady 4
    }
}

proc ui::window::createMainWindow {} {

    wm title . "Fanout Visualizer"
    wm geometry . 1400x900
    wm minsize . 1000 700

    #
    # Root Layout
    #

    frame .root -bg "#1e1e1e"
    pack .root -fill both -expand 1

    #
    # Sidebar
    #

    frame .root.sidebar \
        -bg "#252526" \
        -width 320

    pack .root.sidebar \
        -side left \
        -fill y

    pack propagate .root.sidebar 0

    lassign [ui::canvas::makeScrollable .root.sidebar "#252526"] sidebarCanvas sidebarInner

    #
    # Canvas Area
    #

    frame .root.workspace \
        -bg "#1e1e1e"

    pack .root.workspace \
        -side right \
        -fill both \
        -expand 1

    #
    # Canvas
    #

    set canvas [canvas .root.workspace.c \
        -bg "#1e1e1e" \
        -highlightthickness 0]


    pack .root.workspace.c \
        -fill both \
        -expand 1


    #
    # Status Bar
    #

    label .status \
        -text "Ready" \
        -anchor w \
        -bg "#222" \
        -fg "#d4d4d4" \
        -padx 10

    pack .status \
        -side bottom \
        -fill x

    set ::statusLabel .status

    #
    # Sidebar Title
    #

    set headerFrame [ui::canvas::widget $sidebarInner frame headerFrame -bg "#252526"]
    pack $headerFrame -fill x -padx 16 -pady {16 12}

    set title [ui::canvas::widget $headerFrame label title \
        -text "Fanout Wiz" \
        -bg "#252526" \
        -fg white \
        -font {Helvetica 18 bold}]
    pack $title -anchor w

    set subTitle [ui::canvas::widget $headerFrame label subtitle \
        -text "BGA Fanout control center" \
        -bg "#252526" \
        -fg "#b8c0cc" \
        -font {Helvetica 9}]
    pack $subTitle -anchor w -pady {2 0}

    set overviewFrame [ui::canvas::widget $sidebarInner frame overview -bg "#2a2d31" -highlightbackground "#3b3f46" -highlightthickness 1]
    pack $overviewFrame -fill x -padx 14 -pady {0 14}

    # ui::window::createToolHeader $overviewFrame
    #

    # 
    # Mode Selection 
    # 
    set modeFrame [ui::window::createSection $sidebarInner moe "Tool"]
    ui::window::createActiveText $modeFrame modeLabel "Active Tool: select"
    set modeControls [ui::window::buildControls $modeFrame {
        {button changeMode "Switch Tool" controller::tools::toggleTool}
    }]
    
    # 
    # BGA Geometry Section
    #
    set geometryFrame [ui::window::createSection $sidebarInner geometry "BGA Geometry"]
    #
    # Rows and Cols Controls
    #
    set geometryControls [ui::window::buildControls $geometryFrame {
        {slider rows  "Rows"  2 20 3 1}
        {slider cols  "Cols"  2 20 3 1}
        {entry  pitch "Pitch (mm)" 1}
    }]
    set rowsSlider [dict get $geometryControls rows]
    set colsSlider [dict get $geometryControls cols]

    controller::binding::bind rows  structureConfig.bga.rows
    controller::binding::bind cols  structureConfig.bga.cols
    controller::binding::bind pitch structureConfig.bga.pitch units::mm

    #
    # segWidth and length
    #
    set segFrame [ui::window::createSection $sidebarInner segment "Segment control"]

    set segmentControls [ui::window::buildControls $segFrame {
        # _ name label from to initial resolution
        {slider width "Width" 0.1 0.4 0.1 0.05}
        {slider length "Length" 0.1 0.4 0.1 0.05}
    }]
    set widthSlider [dict get $segmentControls width]
    set lengthSlider [dict get $segmentControls length]

    controller::binding::bind width structureConfig.rules.traceWidth
    controller::binding::bind length structureConfig.rules.neckLength

    
    #
    # Action Panel
    #
    set actionFrame [ui::window::createSection $sidebarInner actionPanel "Actions"]

    set actionControls [ui::window::buildControls $actionFrame {
        # _ name label command
        {button apply "Apply Changes" controller::applyAndEnableSelection}
    }]
    set applyButton [dict get $actionControls apply]

    # Policy Panel
    set structurePolicyFrame [ui::window::createSection $sidebarInner prefsPanel "Policies"]

    set structurePolicyControl [ui::window::createComboControl $structurePolicyFrame structurePolicy "Structure preset" [lsort [array names ::fanout::structures::registry]] ::ui::window::structurePreset]
    set structurePolicyCombo [dict get $structurePolicyControl combo]
    set ::ui::window::structurePreset basic

    pack $structurePolicyCombo -fill x -padx 12 -pady {4 10}

    bind $structurePolicyCombo <<ComboboxSelected>> "controller::setStructurePreset \[%W get\]; ui::window::refreshSectionParamOverrideControls $structurePolicyFrame \[%W get\] policy"
    ui::window::refreshSectionParamOverrideControls $structurePolicyFrame $::ui::window::structurePreset policy

    # via Panel
    set structureViaFrame [ui::window::createSection $sidebarInner viaPanel "Via Configuration"]

    set structureViaControl [ui::window::createComboControl $structureViaFrame viaStructure "Via structure preset" [lsort [array names ::fanout::structures::viaTypes]] ::ui::window::viaStructurePreset]
    set structureViaCombo [dict get $structureViaControl combo]
    set ::ui::window::viaStructurePreset through
    pack $structureViaCombo -fill x -padx 12 -pady {4 10}

    bind $structureViaCombo <<ComboboxSelected>> "ui::window::refreshSectionParamOverrideControls $structureViaFrame \[%W get\] via"
    ui::window::refreshSectionParamOverrideControls $structureViaFrame $::ui::window::viaStructurePreset via

    return .root.workspace.c
}
