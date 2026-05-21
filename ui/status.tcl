namespace eval ui::status {}

proc ui::status::set {msg} {
    if {[info exists ::statusLabel]} {
        $::statusLabel configure -text $msg
    }
}