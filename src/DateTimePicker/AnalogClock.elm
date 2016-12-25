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
import Dict
import String


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
                        g [] (minutes |> Dict.toList |> List.map clockFace)

                    _ ->
                        g [] (hours |> Dict.toList |> List.map clockFace)
                , arrow stateValue
                ]
            ]


clockFace : ( String, Float ) -> Svg msg
clockFace ( number, radians ) =
    let
        point =
            DateTimePicker.Geometry.calculateArrowPoint originPoint 85 radians
    in
        text_
            [ x <| toString point.x
            , y <| toString point.y
            , textAnchor "middle"
            , Svg.Attributes.dominantBaseline "central"
            ]
            [ text number ]


originPoint : Point
originPoint =
    Point 100 100


axisPoint : Point
axisPoint =
    Point 200 100


arrow : StateValue -> Svg msg
arrow stateValue =
    let
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
                    -- |> arrowPoint
                    |>
                        draw


onMouseOverWithPosition : InternalState -> Maybe Date -> (InternalState -> Maybe Date -> msg) -> Svg.Attribute msg
onMouseOverWithPosition state date onChange =
    let
        updateState mouseMoveData =
            let
                stateValue =
                    getStateValue state

                decoder updatedState =
                    Json.Decode.succeed (onChange updatedState date)
            in
                case stateValue.activeTimeIndicator of
                    Just (DateTimePicker.State.HourIndicator) ->
                        decoder (updateHourState stateValue date mouseMoveData)

                    Just (DateTimePicker.State.MinuteIndicator) ->
                        decoder (updateMinuteState stateValue date mouseMoveData)

                    _ ->
                        decoder (InternalState stateValue)
    in
        Svg.Events.on "mousemove"
            (mouseMoveDecoder |> Json.Decode.andThen updateState)


updateHourState : StateValue -> Maybe Date -> MouseMoveData -> InternalState
updateHourState stateValue date mouseMoveData =
    let
        currentAngle =
            DateTimePicker.Geometry.calculateAngle originPoint axisPoint (Point mouseMoveData.offsetX mouseMoveData.offsetY)

        closestHour =
            hours
                |> Dict.toList
                |> List.map (\( hour, radians ) -> ( ( hour, radians ), abs (radians - currentAngle) ))
                |> List.sortBy Tuple.second
                |> List.head
                |> Maybe.map (Tuple.first)
                |> Maybe.map (\( hour, radians ) -> ( hour, DateTimePicker.Geometry.calculateArrowPoint originPoint 70 radians ))

        updateTime time hour =
            { time | hour = hour |> Maybe.andThen (String.toInt >> Result.toMaybe) }
    in
        InternalState
            { stateValue
                | clockMousePosition =
                    Maybe.map Tuple.second closestHour
                , time = updateTime stateValue.time (Maybe.map Tuple.first closestHour)
            }


updateMinuteState : StateValue -> Maybe Date -> MouseMoveData -> InternalState
updateMinuteState stateValue date mouseMoveData =
    InternalState { stateValue | clockMousePosition = Just { x = mouseMoveData.offsetX, y = mouseMoveData.offsetY } }


type alias MouseMoveData =
    { offsetX : Int, offsetY : Int }


mouseMoveDecoder : Json.Decode.Decoder MouseMoveData
mouseMoveDecoder =
    Json.Decode.map2 MouseMoveData
        (Json.Decode.field "offsetX" Json.Decode.int)
        (Json.Decode.field "offsetY" Json.Decode.int)



-- Hour Position


hours : Dict.Dict String Float
hours =
    Dict.fromList
        [ ( "1", pi * 2 / 6 )
        , ( "2", pi * 1 / 6 )
        , ( "3", pi * 2 )
        , ( "4", pi * 11 / 6 )
        , ( "5", pi * 10 / 6 )
        , ( "6", pi * 9 / 6 )
        , ( "7", pi * 8 / 6 )
        , ( "8", pi * 7 / 6 )
        , ( "9", pi )
        , ( "10", pi * 5 / 6 )
        , ( "11", pi * 4 / 6 )
        , ( "12", pi / 2 )
        ]


minutes : Dict.Dict String Float
minutes =
    Dict.fromList
        [ ( "5", pi * 2 / 6 )
        , ( "10", pi * 1 / 6 )
        , ( "15", pi * 2 )
        , ( "20", pi * 11 / 6 )
        , ( "25", pi * 10 / 6 )
        , ( "30", pi * 9 / 6 )
        , ( "35", pi * 8 / 6 )
        , ( "40", pi * 7 / 6 )
        , ( "45", pi )
        , ( "50", pi * 5 / 6 )
        , ( "55", pi * 4 / 6 )
        , ( "0", pi / 2 )
        ]
