namespace eval fanout::render {}

source [file join [file dirname [info script]] canvas.tcl]
source [file join [file dirname [info script]] clineSeg.tcl]
source [file join [file dirname [info script]] via.tcl]
source [file join [file dirname [info script]] fanout.tcl]
source [file join [file dirname [info script]] pads.tcl]
source [file join [file dirname [info script]] highlight.tcl]
source [file join [file dirname [info script]] figs.tcl]
package provide fanout::render 1.0
