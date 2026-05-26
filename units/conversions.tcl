

# ---------------------------------------------------------
# Canonical Internal Unit
#
# ALL geometry in the system is stored internally as:
#
#     micrometers (um)
#
# ---------------------------------------------------------

namespace eval units {}

variable INTERNAL_UNIT "um"


# ---------------------------------------------------------
# Base Unit
# ---------------------------------------------------------

proc units::um {value} {
    return $value
}


# ---------------------------------------------------------
# Millimeters -> um
# ---------------------------------------------------------

proc units::mm {value} {
    return [expr {$value * 1000.0}]
}


# ---------------------------------------------------------
# Inches -> um
# ---------------------------------------------------------

proc units::inch {value} {
    return [expr {$value * 25400.0}]
}


# ---------------------------------------------------------
# Mils -> um
#
# 1 mil = 0.001 inch
#       = 25.4 um
# ---------------------------------------------------------

proc units::mil {value} {
    return [expr {$value * 25.4}]
}


# ---------------------------------------------------------
# um -> mm
# ---------------------------------------------------------

proc units::toMm {value} {
    return [expr {$value / 1000.0}]
}


# ---------------------------------------------------------
# um -> mil
# ---------------------------------------------------------

proc units::toMil {value} {
    return [expr {$value / 25.4}]
}


# ---------------------------------------------------------
# um -> inch
# ---------------------------------------------------------

proc units::toInch {value} {
    return [expr {$value / 25400.0}]
}


# ---------------------------------------------------------
# Pretty Print
# ---------------------------------------------------------

proc units::formatUm {value} {
    return [format "%.3f um" $value]
}

proc units::formatMm {value} {
    return [format "%.3f mm" [toMm $value]]
}

proc units::formatMil {value} {
    return [format "%.3f mil" [toMil $value]]
}