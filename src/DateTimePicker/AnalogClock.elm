module DateTimePicker.AnalogClock exposing (clock)

import Html exposing (Html, div)
import Svg
import Svg.Attributes exposing (width, height, viewBox, cx, cy, r, fill, stroke, strokeWidth, x1, y1, x2, y2)
import Svg.Events
import DateTimePicker.SharedStyles exposing (datepickerNamespace, CssClasses(..))
import DateTimePicker.State exposing (InternalState(..), StateValue, getStateValue)
import Date exposing (Date)
import Json.Decode
import DateTimePicker.Geometry exposing (Point)


{ id, class, classList } =
    datepickerNamespace


clock : (InternalState -> Maybe Date -> msg) -> InternalState -> Maybe Date -> Html msg
clock onChange state date =
    let
        stateValue =
            getStateValue state
    in
        div [ class [ AnalogClock ] ]
            [ Svg.svg [ width "200", height "200", viewBox "0 0 200 200" ]
                [ Svg.circle
                    [ cx "100"
                    , cy "100"
                    , r "100"
                    , fill "#eee"
                      -- , strokeWidth "1px"
                      -- , stroke "#aaa"
                    , onMouseOverWithPosition state date (onChange)
                    ]
                    []
                , arrow stateValue
                ]
            ]


arrow stateValue =
    let
        originPoint =
            Point 100 100

        axisPoint =
            Point 200 100

        arrowPoint point =
            point
                |> DateTimePicker.Geometry.calculateAngle originPoint axisPoint
                |> DateTimePicker.Geometry.calculateArrowPoint originPoint 80

        draw point =
            Svg.line
                [ x1 "100"
                , y1 "100"
                , x2 <| toString point.x
                , y2 <| toString point.y
                , strokeWidth "2px"
                , stroke "#aaa"
                ]
                []
    in
        case stateValue.clockMousePosition of
            Nothing ->
                Svg.text ""

            Just point ->
                point
                    |> arrowPoint
                    |> draw


onMouseOverWithPosition state date onChange =
    let
        updateState value =
            let
                stateValue =
                    getStateValue state

                updatedState =
                    InternalState { stateValue | clockMousePosition = Just { x = value.offsetX, y = value.offsetY } }
            in
                Json.Decode.succeed (onChange updatedState date)
    in
        Svg.Events.on "mousemove"
            (mouseMoveDecoder |> Json.Decode.andThen updateState)


type alias MouseMoveData =
    { offsetX : Int, offsetY : Int }


mouseMoveDecoder =
    Json.Decode.map2 MouseMoveData
        (Json.Decode.field "offsetX" Json.Decode.int)
        (Json.Decode.field "offsetY" Json.Decode.int)
