namespace eval strategy::fanout {}

proc strategy::fanout::escape4way {bga} {

    set rows [dict get $bga rows]
    set cols [dict get $bga cols]
    set pitch [dict get $bga pitch]

    set cx [expr {($cols - 1) / 2.0}]
    set cy [expr {($rows - 1) / 2.0}]

    set padsIn [model::bga::generatePads $bga]

    set resultPads {}

    foreach padName [dict keys $padsIn] {

        set pad [dict get $padsIn $padName]

        set col [dict get $pad col]
        set row [dict get $pad row]

        set x [dict get $pad x]
        set y [dict get $pad y]

        # -----------------------------
        # 1. ESCAPE DIRECTION LOGIC
        # -----------------------------
        set dx [expr {$col - $cx}]
        set dy [expr {$row - $cy}]

        if {abs($dx) > abs($dy)} {
            if {$dx > 0} {
                set dir "E"
            } else {
                set dir "W"
            }
        } else {
            if {$dy > 0} {
                set dir "N"
            } else {
                set dir "S"
            }
        }

        # -----------------------------
        # 2. SIMPLE VIA PLACEMENT
        # (placeholder: offset 1 pitch outward)
        # -----------------------------
        set viaX $x
        set viaY $y

        if {$dir eq "N"} {
            set viaY [expr {$y + $pitch}]
        } elseif {$dir eq "S"} {
            set viaY [expr {$y - $pitch}]
        } elseif {$dir eq "E"} {
            set viaX [expr {$x + $pitch}]
        } elseif {$dir eq "W"} {
            set viaX [expr {$x - $pitch}]
        }

        # -----------------------------
        # 3. BUILD PAD FANOUT IR
        # -----------------------------
        dict set resultPads $padName padId $padName

        dict set resultPads $padName position x $x
        dict set resultPads $padName position y $y

        dict set resultPads $padName escape direction $dir
        dict set resultPads $padName escape priority 1

        dict set resultPads $padName via exists 1
        dict set resultPads $padName via x $viaX
        dict set resultPads $padName via y $viaY
        dict set resultPads $padName via type "through"

        dict set resultPads $padName status valid 1
    }

    # -----------------------------
    # 4. WRAP RESULT
    # -----------------------------
    return [dict create \
        strategyId "escape4way_v1" \
        pads $resultPads \
        summary [dict create \
            totalPads [llength [dict keys $resultPads]] \
            routedPads [llength [dict keys $resultPads]] \
            failedPads 0 \
        ] \
    ]
}