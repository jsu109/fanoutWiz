namespace eval ui::canvas {}

proc ui::canvas::widget {parent type name args} {
    set path "$parent.$name"
    if {[string equal $type frame]} {
        frame $path {*}$args
    } elseif {[string equal $type label]} {
        label $path {*}$args
    } elseif {[string equal $type button]} {
        set cleanArgs {}
        set unsupported { -bg -fg -activebackground -activeforeground -relief -borderwidth -padx -pady -highlightthickness -highlightbackground -highlightcolor }
        foreach {opt value} $args {
            if {$opt ni $unsupported} {
                lappend cleanArgs $opt $value
            }
        }
        ttk::button $path {*}$cleanArgs
    } elseif {[string equal $type entry]} {
        ttk::entry $path {*}$args
    } elseif {[string equal $type checkbutton]} {
        ttk::checkbutton $path {*}$args
    } elseif {[string equal $type combobox]} {
        ttk::combobox $path {*}$args
    } elseif {[string equal $type scale]} {
        scale $path {*}$args
    } else {
        eval $type $path $args
    }
    return $path
}

proc ui::canvas::attachWindow {canvas framePath} {
    if {![winfo exists $framePath]} {
        error "Frame path '$framePath' does not exist"
    }

    if {[llength [$canvas find withtag uiCanvasWindow]] == 0} {
        $canvas create window 0 0 -anchor nw -window $framePath -tags uiCanvasWindow
    } else {
        $canvas itemconfigure uiCanvasWindow -window $framePath
    }

    bind $canvas <Configure> [list ui::canvas::refreshScrollRegion $canvas $framePath]
    bind $framePath <Configure> [list ui::canvas::refreshScrollRegion $canvas $framePath]
    ui::canvas::refreshScrollRegion $canvas $framePath

    return $framePath
}

proc ui::canvas::refreshScrollRegion {canvas framePath} {
    set width [winfo width $canvas]
    if {$width <= 0} {
        set width [winfo reqwidth $canvas]
    }

    set height [winfo reqheight $framePath]
    if {$height <= 0} {
        set height [winfo height $framePath]
    }

    $canvas itemconfigure uiCanvasWindow -width $width
    $canvas configure -scrollregion [list 0 0 $width $height]
}

proc ui::canvas::makeScrollable {parent {bg "#252526"}} {
    if {[winfo exists $parent.scroll]} {
        destroy $parent.scroll
    }
    if {[winfo exists $parent.canvas]} {
        destroy $parent.canvas
    }
    if {[winfo exists $parent.inner]} {
        destroy $parent.inner
    }

    ttk::scrollbar $parent.scroll -orient vertical
    canvas $parent.canvas -bg $bg -highlightthickness 0 -yscrollcommand "$parent.scroll set"
    frame $parent.inner -bg $bg

    pack $parent.scroll -side right -fill y
    pack $parent.canvas -side left -fill both -expand 1

    $parent.scroll configure -command "$parent.canvas yview"
    ui::canvas::attachWindow $parent.canvas $parent.inner

    return [list $parent.canvas $parent.inner]
}
