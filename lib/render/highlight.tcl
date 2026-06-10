namespace eval render::highlight {}
variable highlightedItemsDict
variable canvas

set highlightedItemsDict {}
proc render::highlight::highlightFeature {canvas featureId highlightColor} {
    set canvas $canvas
    variable highlightedItemsDict

    foreach item [$canvas find withtag feature:$featureId] {

        set typeTags [$canvas gettags $item]

        set currentFill [$canvas itemcget $item -fill]

        dict set highlightedItemsDict $item $currentFill

        if {"seg" in $typeTags} {
            $canvas itemconfigure $item -fill $highlightColor
        } elseif {"pad" in $typeTags} {
            $canvas itemconfigure $item -fill $highlightColor
        } elseif {"via" in $typeTags} {
            $canvas itemconfigure $item -fill $highlightColor
        }
    }
}
proc render::highlight::clearAllHighlights {canvas} {

    variable highlightedItemsDict

    foreach item [dict keys $highlightedItemsDict] {

        set typeTags [$canvas gettags $item]

        set original [dict get $highlightedItemsDict $item]

        if {"seg" in $typeTags} {
            $canvas itemconfigure $item -fill $original
        } elseif {"pad" in $typeTags} {
            $canvas itemconfigure $item -fill $original
        } elseif {"via" in $typeTags} {
            $canvas itemconfigure $item -fill $original
        }
    }

    set highlightedItemsDict {}
}
proc render::highlight::clearHighlight {canvas featureId} {
    
    variable highlightedItemsDict

    foreach item [dict keys $highlightedItemsDict] {

        set typeTags [$canvas gettags $item]

        set original [dict get $highlightedItemsDict $item]

        if {"feature:$featureId" in $typeTags} {
            if {"seg" in $typeTags} {
                $canvas itemconfigure $item -fill $original
            } elseif {"pad" in $typeTags} {
                $canvas itemconfigure $item -fill $original
            } elseif {"via" in $typeTags} {
                $canvas itemconfigure $item -fill $original
            }
            dict unset highlightedItemsDict $item
        }
    }
}