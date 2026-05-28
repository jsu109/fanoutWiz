namespace eval render::clineSeg {}

proc render::clineSeg::drawClineSegs {canvas frame} {
    
    # -----------------------------
    # styling defaults
    # -----------------------------
    set color "#035efc"
    set width [units::mm 0.1]

    if {[dict exists $frame color]} {
        set color [dict get $frame color]
    }

    if {[dict exists $frame width]} {
        set width [dict get $frame width]
    }

    # -----------------------------
    # get segments safely
    # -----------------------------
    if {![dict exists $frame segs]} {
        puts "No segments found in frame"
        return
    }
    puts "frame Keys: [dict keys $frame]"
    set segs [dict get $frame segs]
    
    # -----------------------------
    # view transform
    # -----------------------------
    set scale 1.0
    set ox 0
    set oy 0

    if {[info exists ::view::scale]} {
        set scale $::view::scale
    }

    if {[info exists ::view::offsetX]} {
        set ox $::view::offsetX
    }

    if {[info exists ::view::offsetY]} {
        set oy $::view::offsetY
    }

    dict for {padId padClines} $segs {

        # -----------------------------
        # robust normalization
        # -----------------------------
        set segDict $padClines

        # unwrap: padClines {segments {...}}
        if {[dict exists $segDict segments]} {
            set maybe [dict get $segDict segments]

            # if this is the real segment container (neck/escape), unwrap it
            if {[dict exists $maybe neck] || [dict exists $maybe escape]} {
                set segDict $maybe
            } else {
                set segDict $maybe
            }
        }

        dict for {segKey segData} $segDict {


            # -----------------------------
            # extract geometry (robust IR handling)
            # -----------------------------
            dict for {key data} $segData {
            

                if {[dict exists $data geometry]} {
                    set geom [dict get $data geometry]
                } else {
                    set geom $data
                }
                puts $geom

                # validate geometry
                if {![dict exists $geom x1] || ![dict exists $geom x2]} {
                    puts "WARN: skipping invalid segment in $padId -> $segKey : $segData"
                    continue
                }

                set x1 [dict get $geom x1]
                set y1 [dict get $geom y1]
                set x2 [dict get $geom x2]
                set y2 [dict get $geom y2]

                # -----------------------------
                # transform
                # -----------------------------
                set x1 [expr {$x1 * $scale + $ox}]
                set y1 [expr {$y1 * $scale + $oy}]
                set x2 [expr {$x2 * $scale + $ox}]
                set y2 [expr {$y2 * $scale + $oy}]

                # -----------------------------
                # draw
                # -----------------------------
                set segWidth $width
                if {[dict exists $data width]} {
                    set segWidth [expr {[dict get $data width] * $scale}]
                }

                $canvas create line \
                    $x1 $y1 $x2 $y2 \
                    -fill $color \
                    -width $segWidth
            }
        }
    }
}