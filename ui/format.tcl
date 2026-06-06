namespace eval ui::format {}

proc ui::format::distance {distance_um} {
    set distance_mm [expr {$distance_um / 1000.0}]
    return [format "%.2f mm" $distance_mm]
}