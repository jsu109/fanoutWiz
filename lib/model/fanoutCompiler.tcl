namespace eval model::fanoutCompiler {}

proc model::fanoutCompiler::compile {fanout} {

    set segments {}
    
    set pads [dict get $fanout pads]

    # -------------------------------------------------
    # fallback parameters (can later come from BGA config)
    # -------------------------------------------------
    set defaultLength [units::mm 0.5]  ;# µm (safe starter escape distance)
    set width [units::mm 0.1]

    foreach padId [dict keys $pads] {
        
        set p [dict get $pads $padId]

        # -------------------------
        # pad geometry (µm)
        # -------------------------
        set x [dict get $p position x]
        set y [dict get $p position y]

        set dir [dict get $p escape direction]

        # -------------------------
        # direction → vector
        # -------------------------
        set dx 0
        set dy 0

        switch $dir {
            "N" { set dx 0;  set dy 1 }
            "S" { set dx 0;  set dy -1 }
            "E" { set dx 1;  set dy 0 }
            "W" { set dx -1; set dy 0 }
            default { set dx 0; set dy 1 }
        }
        puts $p 
        # -------------------------
        # length model (can evolve later)
        # -------------------------
        set length $defaultLength

        # -------------------------
        # compute geometry
        # -------------------------
        set x2 [expr {$x + $dx * $length}]
        set y2 [expr {$y + $dy * $length}]

        # -------------------------
        # build segment IR (NO clineSeg dependency)
        # -------------------------
        set seg1 [dict create \
            id seg1 \
            width $width \
            length $length \
            angle 0 \
            geometry [dict create \
                x1 $x y1 $y \
                x2 $x2 y2 $y2 \
            ] \
            nodes [dict create \
                from $padId \
                to "$padId.exit" \
            ] \
        ]
        # -------------------------
        # attach to output
        # -------------------------
        dict set segments $padId seg1 $seg1
        
        
    }

    return [dict create segments $segments]
}