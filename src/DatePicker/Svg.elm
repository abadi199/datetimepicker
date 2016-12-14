module DatePicker.Svg
    exposing
        ( leftArrow
        , rightArrow
        , upArrow
        , downArrow
        )

import Svg exposing (Svg, svg, polygon)
import Svg.Attributes exposing (width, height, viewBox, points, style)


type Orientation
    = Up
    | Down
    | Left
    | Right


rightArrow : Svg msg
rightArrow =
    arrow Right


leftArrow : Svg msg
leftArrow =
    arrow Left


downArrow : Svg msg
downArrow =
    arrow Down


upArrow : Svg msg
upArrow =
    arrow Up


arrow : Orientation -> Svg msg
arrow orientation =
    let
        rotation =
            case orientation of
                Right ->
                    "0"

                Left ->
                    "180"

                Down ->
                    "90"

                Up ->
                    "270"
    in
        svg [ width "8", height "12", viewBox "0 0 16 16", style <| "transform: rotate(" ++ rotation ++ "deg);" ]
            [ polygon [ points "0 0, 0 20, 16 10" ] []
            ]
