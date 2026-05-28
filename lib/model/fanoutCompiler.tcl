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

        set clines [dict get $p clines]

        # unwrap canonical structure
        if {[dict exists $clines segments]} {
            set clines [dict get $clines segments]
        }

        dict for {segName segData} $clines {

            # normalize segment format (support evolving IR shapes)
            if {[dict exists $segData geometry]} {
                set geometry [dict get $segData geometry]
            } else {
                set geometry $segData
            }

            # validate geometry
            if {![dict exists $geometry x1] || ![dict exists $geometry x2]} {
                puts "WARN: invalid cline geometry for pad $padId seg $segName -> $segData"
                continue
            }

            set seg [dict create \
                id $segName \
                width $width \
                length $defaultLength \
                angle 0 \
                geometry $geometry \
                nodes [dict create \
                    from $padId \
                    to "$padId.exit" \
                ] \
            ]

            dict set segments $padId $segName $seg
        }       
    }

    return [dict create segments $segments]
}