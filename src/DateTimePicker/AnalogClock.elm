module DateTimePicker.AnalogClock exposing (clock)

import Html exposing (Html, div)
import Svg exposing (Svg, svg, circle, line, g, text, text_)
import Svg.Attributes exposing (textAnchor, width, height, viewBox, cx, cy, r, fill, stroke, strokeWidth, x1, y1, x2, y2, x, y)
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
            [ svg [ width "200", height "200", viewBox "0 0 200 200" ]
                [ circle
                    [ cx "100"
                    , cy "100"
                    , r "100"
                    , fill "#eee"
                      -- , strokeWidth "1px"
                      -- , stroke "#aaa"
                    , onMouseOverWithPosition state date (onChange)
                    ]
                    []
                , case stateValue.activeTimeIndicator of
                    Just (DateTimePicker.State.MinuteIndicator) ->
                        g [] (List.map clockFace minutes)

                    _ ->
                        g [] (List.map clockFace hours)
                , arrow stateValue
                ]
            ]


clockFace : ( String, Point ) -> Svg msg
clockFace ( number, point ) =
    text_
        [ x <| toString point.x
        , y <| toString point.y
        , textAnchor "middle"
        , Svg.Attributes.dominantBaseline "central"
        ]
        [ text number ]


arrow : StateValue -> Svg msg
arrow stateValue =
    let
        originPoint =
            Point 100 100

        axisPoint =
            Point 200 100

        length =
            70

        arrowPoint point =
            point
                |> DateTimePicker.Geometry.calculateAngle originPoint axisPoint
                |> DateTimePicker.Geometry.calculateArrowPoint originPoint length

        draw point =
            line
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
                text ""

            Just point ->
                point
                    |> arrowPoint
                    |> draw


onMouseOverWithPosition : InternalState -> Maybe Date -> (InternalState -> Maybe Date -> msg) -> Svg.Attribute msg
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


mouseMoveDecoder : Json.Decode.Decoder MouseMoveData
mouseMoveDecoder =
    Json.Decode.map2 MouseMoveData
        (Json.Decode.field "offsetX" Json.Decode.int)
        (Json.Decode.field "offsetY" Json.Decode.int)



-- Hour Position


hours : List ( String, Point )
hours =
    let
        point =
            DateTimePicker.Geometry.calculateArrowPoint (Point 100 100) 85
    in
        [ ( "1", point (pi * 2 / 6) )
        , ( "2", point (pi * 1 / 6) )
        , ( "3", point (pi * 2) )
        , ( "4", point (pi * 11 / 6) )
        , ( "5", point (pi * 10 / 6) )
        , ( "6", point (pi * 9 / 6) )
        , ( "7", point (pi * 8 / 6) )
        , ( "8", point (pi * 7 / 6) )
        , ( "9", point pi )
        , ( "10", point (pi * 5 / 6) )
        , ( "11", point (pi * 4 / 6) )
        , ( "12", point (pi / 2) )
        ]


minutes : List ( String, Point )
minutes =
    let
        point =
            DateTimePicker.Geometry.calculateArrowPoint (Point 100 100) 85
    in
        [ ( "5", point (pi * 2 / 6) )
        , ( "10", point (pi * 1 / 6) )
        , ( "15", point (pi * 2) )
        , ( "20", point (pi * 11 / 6) )
        , ( "25", point (pi * 10 / 6) )
        , ( "30", point (pi * 9 / 6) )
        , ( "35", point (pi * 8 / 6) )
        , ( "40", point (pi * 7 / 6) )
        , ( "45", point pi )
        , ( "50", point (pi * 5 / 6) )
        , ( "55", point (pi * 4 / 6) )
        , ( "0", point (pi / 2) )
        ]
