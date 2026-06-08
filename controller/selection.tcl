namespace eval controller::selection {
    variable selectedFeatureId ""
}

proc controller::selection::featureSelected {canvas featureId} {
    variable selectedFeatureId
    set selectedFeatureId $featureId

    ui::status::set "Selected: $selectedFeatureId"
    render::highlight::highlightFeature $canvas $featureId green
    controller::tools::dispatch $canvas $featureId
}

proc controller::selection::clear {} {
    variable selectedFeatureId
    set selectedFeatureId ""
}
