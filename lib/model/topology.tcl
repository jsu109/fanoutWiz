namespace eval model::topology {}

proc model::topology::getTopologyProc {structure} {

    dict get {
        orthogonal model::topology::orthogonalEscape
        diagonal   model::topology::diagonalEscape
        dogbone  model::topology::dogboneEscape
        NSEW  model::topology::NSEW
    } $structure
}
proc model::topology::classifyPad {padId bga} {
    set rows [dict get $bga rows]
    set cols [dict get $bga cols]
    
    set padRow [dict get $padId row]
    set padCol [dict get $padId col]

    set centerRow [expr {($rows - 1) / 2.0}]
    set centerCol [expr {($cols - 1) / 2.0}]

    set dRow [expr {$padRow - $centerRow}]
    set dCol [expr {$padCol - $centerCol}]
    
    
    # NW dRow <0, dCol <0
    # NE dRow <0, dCol >0
    # SW dRow >0, dCol <0
    # SE dRow >0, dCol >0

    # Determine quadrant
    if {$dRow < 0 && $dCol < 0} {
        set quadrant NW
    } elseif {$dRow < 0 && $dCol >= 0} {
        set quadrant NE
    } elseif {$dRow >= 0 && $dCol < 0} {
        set quadrant SW
    } else {
        set quadrant SE
    }
    if {abs($dRow) < 0.5 && abs($dCol) < 0.5} {
    set quadrant CENTER
}

    # Determine edge (logic assumes row/col 0th start index). 

    set isTop    [expr {$padRow == 0}]
    set isBottom [expr {$padRow == ($rows - 1)}]
    set isLeft   [expr {$padCol == 0}]
    set isRight  [expr {$padCol == ($cols - 1)}]

    set edgePad [expr {$isTop || $isBottom || $isLeft || $isRight}]
    set edgeSide [list]
    if {$isTop}    {lappend edgeSide "TOP"}
    if {$isBottom} {lappend edgeSide "BOTTOM"}
    if {$isLeft}   {lappend edgeSide "LEFT"}
    if {$isRight}  {lappend edgeSide "RIGHT"}
    
    set padContext [dict create \
                        row $padRow \
                        col $padCol \
                        dRow $dRow \
                        dCol $dCol \
                        quadrant $quadrant \
                        edge $edgeSide]
    return $padContext
    
}
proc model::topology::orthogonalEscape {padContext} {
    # Given:
    #   - pad identity
    #   - BGA dimensions
    #   - topology strategy

    # Determine:
    #   - routing class
    #   - preferred escape direction
    #   - topology parameters
    puts $padContext
    
}

proc model::topology::applyClineToPad {padId bga structure} {

    # TODO: create a Cline object which is defined by a list/dict
    # ClineSegs with a defined Width, length, angle. based on the required
    # structure, bga size and pin location. 
    set topologyProc [model::topology::getTopologyProc $structure]
    set padContext [model::topology::classifyPad $padId $bga]

    return [$topologyProc $padContext]

}

