namespace eval render::highlight {}

proc render::highlight::highlightFeature {canvas featureId highlightColor} {

    foreach item [$canvas find withtag feature:$featureId] {

        set typeTags [$canvas gettags $item]

        if {"seg" in $typeTags} {
            $canvas itemconfigure $item \
                -fill $highlightColor \
        } elseif {"pad" in $typeTags} {
            $canvas itemconfigure $item \
                -fill $highlightColor \
                
        } elseif {"via" in $typeTags} {
            $canvas itemconfigure $item \
                -fill $highlightColor \
        }
    }
}