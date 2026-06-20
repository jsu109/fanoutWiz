namespace eval render::canvas {}

proc render::canvas::clearCanvasItemByTag {canvas tag} {
    
    $canvas delete $tag

}