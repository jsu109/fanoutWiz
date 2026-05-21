namespace eval model::bga {}

proc model::bga::createBGA {{rows 10} {cols 10}} {

    return [dict create \
    rows $rows \
    cols $cols \
    pitch 50 \
    padRadius 8 \
    originX 300 \
    originY 100 \
    defaultPadType circle]
    
}

proc model::bga::generatePads {bgaDef} {
    set pads {}

    set rows [dict get $bgaDef rows]
    set cols [dict get $bgaDef cols]

    set pitch [dict get $bgaDef pitch]

    set originX [dict get $bgaDef originX]
    set originY [dict get $bgaDef originY]

    set defaultPadType [dict get $bgaDef defaultPadType]

    for {set row 0} {$row < $rows} {incr row} {

        for {set col 0} {$col < $cols} {incr col} {

            set x [expr {$originX + $col * $pitch}]
            set y [expr {$originY + $row * $pitch}]

            set rowChar [format %c [expr {65 + $row}]]
            set colNum [expr {$col + 1}]

            set padName "$rowChar$colNum"

            dict set pads $padName row $row
            dict set pads $padName col $col

            dict set pads $padName x $x
            dict set pads $padName y $y

            dict set pads $padName type $defaultPadType
        }
    }

    return $pads
}
