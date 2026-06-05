namespace eval ui::window {}

proc ui::window::collectSectionParamOverrides {sectionName} {
    set overrides [dict create]
    set prefix "::ui::window::${sectionName}_"
    foreach var [info vars ::ui::window::policy_*] {
        set key [string range $var [string length $prefix] end]
        set value [set $var]
        dict set overrides $key [expr {$value ? yes : no}]
    }
    return $overrides
    
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
            -variable $varName]
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
    # Background click catcher
    #

    $canvas create rectangle \
        0 0 5000 5000 \
        -fill "" \
        -outline "" \
        -tags background

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

    set overviewLabel [ui::canvas::widget $overviewFrame label overviewLabel \
        -text "Live session" \
        -bg "#2a2d31" \
        -fg "#8ab4ff" \
        -font {Helvetica 9 bold}]
    pack $overviewLabel -anchor w -padx 12 -pady {10 4}

    set modeValue [ui::canvas::widget $overviewFrame label modeValue \
        -text "EDIT MODE" \
        -bg "#2a2d31" \
        -fg "#4cc2ff" \
        -font {Helvetica 12 bold}]
    pack $modeValue -anchor w -padx 12

    set modeHint [ui::canvas::widget $overviewFrame label modeHint \
        -text "Adjust geometry, apply changes, then run diagnostics." \
        -bg "#2a2d31" \
        -fg "#d5dbe5" \
        -justify left \
        -wraplength 260]
    pack $modeHint -anchor w -padx 12 -pady {4 10}

    set modeToggle [ui::canvas::widget $overviewFrame button modeToggle \
        -text "Switch to SELECT" \
        -bg "#2f78c7" \
        -fg "#eff6ff" \
        -activebackground "#3d8df0" \
        -activeforeground "#ffffff" \
        -relief flat \
        -borderwidth 0 \
        -command controller::toggleMode]
    pack $modeToggle -fill x -padx 12 -pady {0 10}

    set ::modeLabel $modeValue
    #
    # BGA Geometry Section
    #

    set geometryFrame [ui::canvas::widget $sidebarInner frame geometry -bg "#2a2d31" -highlightbackground "#3b3f46" -highlightthickness 1]

    pack $geometryFrame \
        -fill x \
        -padx 14 \
        -pady {0 12}

    set geometryTitle [ui::canvas::widget $geometryFrame label title \
        -text "BGA Geometry" \
        -bg "#2a2d31" \
        -fg white \
        -font {Helvetica 11 bold}]

    pack $geometryTitle \
        -anchor w \
        -padx 12 \
        -pady {10 16}

    #
    # Rows Control
    #

    set rowsFrame [ui::canvas::widget $geometryFrame frame rows -bg "#2a2d31"]

    pack $rowsFrame \
        -fill x \
        -padx 12 \
        -pady 6

    set rowsLabel [ui::canvas::widget $rowsFrame label label -text "Rows" -bg "#2a2d31" -fg "#cccccc"]
    set rowsValue [ui::canvas::widget $rowsFrame label value -text "3" -bg "#2a2d31" -fg "#4cc2ff"]
    set rowsSlider [ui::canvas::widget $rowsFrame scale slider \
        -from 2 \
        -to 20 \
        -orient horizontal \
        -showvalue 0 \
        -length 180 \
        -bg "#2a2d31" \
        -fg white \
        -troughcolor "#3c3c3c" \
        -activebackground "#4cc2ff" \
        -highlightthickness 0 \
        -borderwidth 0]

    $rowsSlider set 3

    pack $rowsLabel -side left
    pack $rowsValue -side right
    pack $rowsSlider -side bottom \
        -fill x \
        -pady {6 0}

    #
    # Cols Control
    #

    set colsFrame [ui::canvas::widget $geometryFrame frame cols -bg "#2a2d31"]

    pack $colsFrame \
        -fill x \
        -padx 12 \
        -pady 6

    set colsLabel [ui::canvas::widget $colsFrame label label -text "Cols" -bg "#2a2d31" -fg "#cccccc"]
    set colsValue [ui::canvas::widget $colsFrame label value -text "3" -bg "#2a2d31" -fg "#4cc2ff"]
    set colsSlider [ui::canvas::widget $colsFrame scale slider \
        -from 2 \
        -to 20 \
        -orient horizontal \
        -showvalue 0 \
        -length 180 \
        -bg "#2a2d31" \
        -fg white \
        -troughcolor "#3c3c3c" \
        -activebackground "#4cc2ff" \
        -highlightthickness 0 \
        -borderwidth 0]

    $colsSlider set 3

    pack $colsLabel -side left
    pack $colsValue -side right
    pack $colsSlider -side bottom \
        -fill x \
        -pady {6 0}

    #
    # Slider Value Updates
    #
    bind $rowsSlider <Motion> [list apply {{rowsValue rowsSlider} {
        $rowsValue configure -text [$rowsSlider get]
    }} $rowsValue $rowsSlider]

    bind $colsSlider <Motion> [list apply {{colsValue colsSlider} {
        $colsValue configure -text [$colsSlider get]
    }} $colsValue $colsSlider]

    #
    # Action Panel
    #
    set actionFrame [ui::canvas::widget $sidebarInner frame actionPanel -bg "#2a2d31" -highlightbackground "#3b3f46" -highlightthickness 1]
    pack $actionFrame -fill x -padx 14 -pady {0 12}

    set actionTitle [ui::canvas::widget $actionFrame label title \
        -text "Actions" \
        -bg "#2a2d31" \
        -fg white \
        -font {Helvetica 11 bold}]
    pack $actionTitle -anchor w -padx 12 -pady {10 8}

    set applyButton [ui::canvas::widget $actionFrame button apply \
        -text "Apply Changes" \
        -bg "#2f78c7" \
        -fg "#eff6ff" \
        -activebackground "#3d8df0" \
        -activeforeground "#ffffff" \
        -relief flat \
        -borderwidth 0 \
        -padx 10 \
        -pady 10 \
        -command controller::applyAndEnableSelection]

    pack $applyButton -fill x -padx 12 -pady {0 8}

    # set dogboneButton [ui::canvas::widget $actionFrame button dogbone \
    #     -text "Dogbone View" \
    #     -bg "#3b556d" \
    #     -fg "#edf3f8" \
    #     -activebackground "#4a738f" \
    #     -activeforeground "#ffffff" \
    #     -relief flat \
    #     -borderwidth 0 \
    #     -padx 10 \
    #     -pady 10 \
    #     -command {controller::build dogbone}]

    # pack $dogboneButton -fill x -padx 12 -pady {0 10}

    # set basicButton [ui::canvas::widget $actionFrame button basic \
    #     -text "Basic View" \
    #     -bg "#3b556d" \
    #     -fg "#edf3f8" \
    #     -activebackground "#4a738f" \
    #     -activeforeground "#ffffff" \
    #     -relief flat \
    #     -borderwidth 0 \
    #     -padx 10 \
    #     -pady 10 \
    #     -command {controller::build basic}]

    # pack $basicButton -fill x -padx 12 -pady {0 10}

    #
    # Render Diagnostics
    #
    

    # set diagnosticsFrame [ui::canvas::widget $sidebarInner frame diagnostics -bg "#2a2d31" -highlightbackground "#3b3f46" -highlightthickness 1]

    # pack $diagnosticsFrame \
    #     -fill x \
    #     -padx 14 \
    #     -pady {0 18}

    # set diagnosticsTitle [ui::canvas::widget $diagnosticsFrame label title \
    #     -text "Render Diagnostics" \
    #     -bg "#2a2d31" \
    #     -fg white \
    #     -font {Helvetica 11 bold}]

    # pack $diagnosticsTitle \
    #     -anchor w \
    #     -padx 12 \
    #     -pady {10 10}

    # set diagnosticsRun [ui::canvas::widget $diagnosticsFrame button run \
    #     -text "Run Render Tests" \
    #     -bg "#3b556d" \
    #     -fg "#edf3f8" \
    #     -activebackground "#4a738f" \
    #     -activeforeground "#ffffff" \
    #     -relief flat \
    #     -borderwidth 0 \
    #     -padx 10 \
    #     -pady 8 \
    #     -command controller::runRenderDiagnostics]

    # pack $diagnosticsRun \
    #     -fill x \
    #     -padx 12 \
    #     -pady {0 8}

    # set diagnosticsResult [ui::canvas::widget $diagnosticsFrame label result \
    #     -text "Not run" \
    #     -bg "#2a2d31" \
    #     -fg "#cccccc" \
    #     -anchor w \
    #     -justify left \
    #     -wraplength 230]

    # pack $diagnosticsResult \
        -fill x \
        -padx 12 \
        -pady {0 12}

    set structurePolicyFrame [ui::canvas::widget $sidebarInner frame prefsPanel -bg "#2a2d31" -highlightbackground "#3b3f46" -highlightthickness 1]
    pack $structurePolicyFrame -fill x -padx 14 -pady {0 18}

    set prefsTitle [ui::canvas::widget $structurePolicyFrame label title \
        -text "Policies" \
        -bg "#2a2d31" \
        -fg white \
        -font {Helvetica 11 bold}]
    pack $prefsTitle -anchor w -padx 12 -pady {10 8}

    set structureLabel [ui::canvas::widget $structurePolicyFrame label structureLabel \
        -text "Structure preset" \
        -bg "#2a2d31" \
        -fg "#cccccc"]
    pack $structureLabel -anchor w -padx 12

    set structureCombo [ui::canvas::widget $structurePolicyFrame combobox structureCombo \
        -values [lsort [array names ::fanout::structures::registry]] \
        -state readonly \
        -textvariable ::ui::window::structurePreset]
    set ::ui::window::structurePreset basic
    pack $structureCombo -fill x -padx 12 -pady {4 10}

    bind $structureCombo <<ComboboxSelected>> "ui::window::refreshSectionParamOverrideControls $structurePolicyFrame \[%W get\] policy"
    ui::window::refreshSectionParamOverrideControls $structurePolicyFrame $::ui::window::structurePreset policy

    # via Section Frame
    set structureViaFrame [ui::canvas::widget $sidebarInner frame viaPanel \
    -bg "#2a2d31" \
    -highlightbackground "#3b3f46" \
    -highlightthickness 1]

    pack $structureViaFrame -fill x -padx 14 -pady {0 18}

    set viaTitle [ui::canvas::widget $structureViaFrame label title \
        -text "Via Configuration" \
        -bg "#2a2d31" \
        -fg white \
        -font {Helvetica 11 bold}]
    pack $viaTitle -anchor w -padx 12 -pady {10 8}

    set structureViaLabel [ui::canvas::widget $structureViaFrame label structureLabel \
        -text "via Structure preset" \
        -bg "#2a2d31" \
        -fg "#cccccc"]
    pack $structureViaLabel -anchor w -padx 12

    set structureViaCombo [ui::canvas::widget $structureViaFrame combobox structureCombo \
        -values [lsort [array names ::fanout::structures::viaTypes]] \
        -state readonly \
        -textvariable ::ui::window::viaStructurePreset]

    set ::ui::window::viaStructurePreset through
    pack $structureViaCombo -fill x -padx 12 -pady {4 10}

    bind $structureViaCombo <<ComboboxSelected>> "ui::window::refreshSectionParamOverrideControls $structureViaFrame \[%W get\] via"
    ui::window::refreshSectionParamOverrideControls $structureViaFrame $::ui::window::viaStructurePreset via

    return .root.workspace.c
}
