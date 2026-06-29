namespace eval fanout::model {}

source [file join [file dirname [info script]] topology.tcl]
source [file join [file dirname [info script]] bga.tcl]
source [file join [file dirname [info script]] clineSeg.tcl]
source [file join [file dirname [info script]] via.tcl]
source [file join [file dirname [info script]] fanout.tcl]
source [file join [file dirname [info script]] structure.tcl]
source [file join [file dirname [info script]] fanoutCompiler.tcl]
source [file join [file dirname [info script]] pads.tcl]
source [file join [file dirname [info script]] measure.tcl]

package provide fanout::model 1.0
