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

proc controller::selection::clearSelection {canvas} {
    variable selectedFeatureId
    set selectedFeatureId ""
    controller::tools::dispatch $canvas $selectedFeatureId
    ui::status::set "No selection"
    # deselect all
    render::highlight::clearAllHighlights $canvas
}
