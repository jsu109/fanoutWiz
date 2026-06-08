namespace eval controller::tools::measure {
    variable firstFeatureId ""
}

proc controller::tools::measure::onFeatureSelected {featureId} {
    variable firstFeatureId
    if {$firstFeatureId eq ""} {
        set firstFeatureId $featureId
    } else {
        # Calculate distance between first and second features
        set featureIndex [dict get $::controller::lastFrame featureIndex]
        set firstFeature [dict get $featureIndex $firstFeatureId]
        set secondFeature [dict get $featureIndex $featureId]

        # Placeholder for actual measurement logic
        puts "Measuring distance between $firstFeatureId and $featureId"
        set distance [model::measure::manhattanDistance $firstFeature $secondFeature]
        ui::status::set "Distance between $firstFeatureId and $featureId: [ui::format::distance $distance]"

        set firstFeatureId ""
    }
}

proc controller::tools::measure::reset {} {
    variable firstFeatureId
    set firstFeatureId ""
}

