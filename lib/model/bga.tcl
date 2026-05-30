namespace eval model::bga {}

proc model::bga::option {options key defaultValue} {
    if {[dict exists $options $key]} {
        return [dict get $options $key]
    }

    return $defaultValue
}

proc model::bga::createBGA {{rows 5} {cols 5} {options {}}} {
    set pitch [model::bga::option $options pitch [units::mm 1]]
    set ballDiameter [model::bga::option $options ballDiameter [units::mm 0.5]]
    set padScale [model::bga::option $options padScale 0.8]
    set padDiameter [model::bga::option $options padDiameter [expr {$ballDiameter * $padScale}]]
    set defaultPadType [model::bga::option $options defaultPadType circle]

    return [dict create \
        rows $rows \
        cols $cols \
        pitch $pitch \
        ballDiameter $ballDiameter \
        padScale $padScale \
        padDiameter $padDiameter \
        padRadius [expr {$padDiameter / 2.0}] \
        defaultPadType $defaultPadType]
    
}

proc model::bga::deriveRules {bgaDef} {
    set pitch [dict get $bgaDef pitch]
    set padDiameter [dict get $bgaDef padDiameter]

    set channelWidth [expr {$pitch - $padDiameter}]
    set diagonalPitch [expr {sqrt(2.0 * $pitch * $pitch)}]
    set availableDiagonalSpace [expr {$diagonalPitch - $padDiameter}]

    return [dict create \
        channelWidth $channelWidth \
        diagonalPitch $diagonalPitch \
        availableDiagonalSpace $availableDiagonalSpace]
}

proc model::bga::generatePads {bgaDef} {
    set pads {}

    set rows [dict get $bgaDef rows]
    set cols [dict get $bgaDef cols]
    set pitch [dict get $bgaDef pitch]
    set defaultPadType [dict get $bgaDef defaultPadType]

    # Center-based coordinate system (stable, does not drift with size)
    set cx [expr {($cols - 1) / 2.0}]
    set cy [expr {($rows - 1) / 2.0}]

    for {set row 0} {$row < $rows} {incr row} {
        for {set col 0} {$col < $cols} {incr col} {

            # stable world coordinates (no origin drift)
            set x [expr {($col - $cx) * $pitch}]
            set y [expr {($row - $cy) * $pitch}]

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
