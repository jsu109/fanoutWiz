namespace eval controller::tools::measure {
    variable firstFeatureId ""
    variable oldFirstFeatureId ""
}
# there are some bugs with deselecting, need to move that stuff out of measure and into selection, then have measure listen for selection changes and reset itself when selection is cleared or changed to a different feature. For now, just reset the firstFeatureId when the same feature is clicked twice or when an empty area is clicked.
proc controller::tools::measure::onFeatureSelected {canvas featureId} {
    variable firstFeatureId
    variable oldFirstFeatureId
    puts "Feature selected for measurement: $featureId"
    if {$firstFeatureId eq ""} {
        set firstFeatureId $featureId
        return
    } 
    if {$firstFeatureId eq $featureId} {
        # User clicked the same feature twice, reset selection
        set firstFeatureId ""
        return
    } 
    if {$featureId eq ""} {
        # User deselected by clicking on empty space, reset selection
        set firstFeatureId ""
        return
    } 
    if {$oldFirstFeatureId ne ""} {
        # dehighlight previous first feature if it exists
        render::highlight::clearHighlight $canvas $oldFirstFeatureId
        puts "Clearing highlight for old first feature: $oldFirstFeatureId"
        set oldFirstFeatureId ""
    }
    
    # Calculate distance between first and second features
    set featureIndex [dict get $::controller::lastFrame featureIndex]
    set firstFeature [dict get $featureIndex $firstFeatureId]
    set secondFeature [dict get $featureIndex $featureId]

    
    puts "Measuring distance between $firstFeatureId and $featureId"
    set euclidean [model::measure::euclideanDistance $firstFeature $secondFeature]
    set manhattan [model::measure::manhattanDistance $firstFeature $secondFeature]
    ui::status::set "Distance between $firstFeatureId and $featureId: [ui::format::distance $euclidean] (Euclidean), [ui::format::distance $manhattan] (Manhattan)"

    set oldFirstFeatureId $firstFeatureId
    set firstFeatureId $featureId
    
}

proc controller::tools::measure::measureBetween {canvas featureId1 featureId2} {
    variable firstFeatureId
    set firstFeatureId ""

    set featureIndex [dict get $::controller::lastFrame featureIndex]
    set feature1 [dict get $featureIndex $featureId1]
    set feature2 [dict get $featureIndex $featureId2]

    puts "Measuring distance between $featureId1 and $featureId2"
    set euclidean [model::measure::euclideanDistance $feature1 $feature2]
    set manhattan [model::measure::manhattanDistance $feature1 $feature2]
    ui::status::set "Distance between $featureId1 and $featureId2: [ui::format::distance $euclidean] (Euclidean), [ui::format::distance $manhattan] (Manhattan)"
    controller::tools::measure::drawLine $canvas $feature1 $feature2
}
proc controller::tools::measure::drawLine {canvas featureId1 featureId2} {
    set resolvedFeat1 [model::measure::resolveFeature $featureId1]
    set resolvedFeat2 [model::measure::resolveFeature $featureId2]
    render::canvas::clearCanvasItemByTag $canvas {measurementLine}
    render::figs::drawline $canvas $resolvedFeat1 $resolvedFeat2

}

proc controller::tools::measure::reset {} {
    variable firstFeatureId
    set firstFeatureId ""
}

