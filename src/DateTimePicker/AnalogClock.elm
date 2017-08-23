module DateTimePicker.AnalogClock exposing (clock)

import Date exposing (Date)
import DateTimePicker.ClockUtils exposing (hours, minutes, minutesPerFive)
import DateTimePicker.Events exposing (MoveData, onMouseDownPreventDefault, onMouseMoveWithPosition, onPointerMoveWithPosition, onPointerUp, onTouchMovePreventDefault)
import DateTimePicker.Geometry exposing (Point)
import DateTimePicker.Helpers exposing (Type(..), updateCurrentDate, updateTimeIndicator)
import DateTimePicker.Internal exposing (InternalState(..))
import DateTimePicker.SharedStyles exposing (CssClasses(..), datepickerNamespace)
import Dict
import Html exposing (Html, div)
import Json.Decode
import String
import Svg exposing (Svg, circle, g, line, svg, text, text_)
import Svg.Attributes exposing (cx, cy, fill, height, r, stroke, strokeWidth, textAnchor, viewBox, width, x, x1, x2, y, y1, y2)


{ id, class, classList } =
    datepickerNamespace


hourArrowLength : Int
hourArrowLength =
    50


minuteArrowLength : Int
minuteArrowLength =
    70


clock : (InternalState -> Maybe Date -> msg) -> InternalState -> Maybe Date -> Html msg
clock onChange ((InternalState stateValue) as state) date =
    div
        [ class [ AnalogClock ]
        ]
        [ svg
            [ width "200"
            , height "200"
            , viewBox "0 0 200 200"
            ]
            [ circle
                [ cx "100"
                , cy "100"
                , r "100"
                , fill "#eee"
                , onMouseDownPreventDefault (mouseDownHandler state date onChange)
                , onPointerUp (mouseDownHandler state date onChange)
                , onMouseMoveWithPosition (mouseOverHandler state date onChange)
                , onTouchMovePreventDefault (onChange state date)
                , onPointerMoveWithPosition (mouseOverHandler state date onChange)
                ]
                []
            , case stateValue.activeTimeIndicator of
                Just DateTimePicker.Internal.MinuteIndicator ->
                    g [] (minutesPerFive |> Dict.toList |> List.map (clockFace onChange state date))

                _ ->
                    g [] (hours |> Dict.toList |> List.map (clockFace onChange state date))
            , arrow onChange state date
            , currentTime onChange state date
            ]
        ]


currentTime : (InternalState -> Maybe Date -> msg) -> InternalState -> Maybe Date -> Svg msg
currentTime onChange (InternalState state) date =
    let
        time =
            state.time

        hourArrowLength =
            50

        drawHour hour minute =
            Dict.get (toString hour) hours
                |> Maybe.map (flip (-) (toFloat minute * pi / 360))
                |> Maybe.map (DateTimePicker.Geometry.calculateArrowPoint originPoint hourArrowLength >> drawArrow onChange (InternalState state) date)
                |> Maybe.withDefault (text "")

        drawMinute minute =
            Dict.get (toString minute) minutes
                |> Maybe.map (DateTimePicker.Geometry.calculateArrowPoint originPoint minuteArrowLength >> drawArrow onChange (InternalState state) date)
                |> Maybe.withDefault (text "")
    in
    case ( state.activeTimeIndicator, time.hour, time.minute, time.amPm ) of
        ( Nothing, Just hour, Just minute, Just _ ) ->
            g [] [ drawHour hour minute, drawMinute minute ]

        _ ->
            text ""


clockFace : (InternalState -> Maybe Date -> msg) -> InternalState -> Maybe Date -> ( String, Float ) -> Svg msg
clockFace onChange state date ( number, radians ) =
    let
        point =
            DateTimePicker.Geometry.calculateArrowPoint originPoint 85 radians
    in
    text_
        [ x <| toString point.x
        , y <| toString point.y
        , textAnchor "middle"
        , Svg.Attributes.dominantBaseline "central"
        , onMouseDownPreventDefault (mouseDownHandler state date onChange)
        , onPointerUp (mouseDownHandler state date onChange)
        ]
        [ text number ]


originPoint : Point
originPoint =
    Point 100 100


axisPoint : Point
axisPoint =
    Point 200 100


arrow : (InternalState -> Maybe Date -> msg) -> InternalState -> Maybe Date -> Svg msg
arrow onChange (InternalState state) date =
    let
        length =
            case state.activeTimeIndicator of
                Just DateTimePicker.Internal.HourIndicator ->
                    hourArrowLength

                Just DateTimePicker.Internal.MinuteIndicator ->
                    minuteArrowLength

                _ ->
                    0

        arrowPoint angle =
            angle
                |> DateTimePicker.Geometry.calculateArrowPoint originPoint length

        isJust maybe =
            case maybe of
                Just _ ->
                    True

                Nothing ->
                    False

        shouldDrawArrow =
            case state.activeTimeIndicator of
                Just DateTimePicker.Internal.HourIndicator ->
                    isJust state.time.hour

                Just DateTimePicker.Internal.MinuteIndicator ->
                    isJust state.time.minute

                _ ->
                    False
    in
    case state.currentAngle of
        Nothing ->
            text ""

        Just angle ->
            if shouldDrawArrow then
                angle
                    |> arrowPoint
                    |> drawArrow onChange (InternalState state) date
            else
                text ""


drawArrow : (InternalState -> Maybe Date -> msg) -> InternalState -> Maybe Date -> Point -> Svg msg
drawArrow onChange state date point =
    line
        [ x1 "100"
        , y1 "100"
        , x2 <| toString point.x
        , y2 <| toString point.y
        , strokeWidth "2px"
        , stroke "#aaa"
        , onMouseDownPreventDefault (mouseDownHandler state date onChange)
        , onPointerUp (mouseDownHandler state date onChange)
        ]
        []


mouseDownHandler : InternalState -> Maybe Date -> (InternalState -> Maybe Date -> msg) -> msg
mouseDownHandler (InternalState state) date onChange =
    let
        updatedDate =
            updateCurrentDate TimeType (InternalState state)

        updatedStateValue =
            case ( updatedDate, state.activeTimeIndicator ) of
                ( Just _, _ ) ->
                    { state | event = "analog.mouseDownHandler", activeTimeIndicator = Nothing, currentAngle = Nothing }

                ( _, Just DateTimePicker.Internal.HourIndicator ) ->
                    { state | event = "analog.mouseDownHandler", activeTimeIndicator = Just DateTimePicker.Internal.MinuteIndicator, currentAngle = Nothing }

                ( _, Just DateTimePicker.Internal.MinuteIndicator ) ->
                    { state | event = "analog.mouseDownHandler", activeTimeIndicator = Just DateTimePicker.Internal.AMPMIndicator, currentAngle = Nothing }

                _ ->
                    { state | event = "analog.mouseDownHandler", activeTimeIndicator = Just DateTimePicker.Internal.HourIndicator, currentAngle = Nothing }
    in
    onChange
        (updateTimeIndicator <| InternalState state)
        updatedDate


mouseOverHandler : InternalState -> Maybe Date -> (InternalState -> Maybe Date -> msg) -> MoveData -> Json.Decode.Decoder msg
mouseOverHandler (InternalState state) date onChange moveData =
    let
        decoder updatedState =
            Json.Decode.succeed (onChange updatedState date)
    in
    case state.activeTimeIndicator of
        Just DateTimePicker.Internal.HourIndicator ->
            decoder (updateHourState (InternalState state) date moveData)

        Just DateTimePicker.Internal.MinuteIndicator ->
            decoder (updateMinuteState (InternalState state) date moveData)

        _ ->
            decoder (InternalState state)


updateHourState : InternalState -> Maybe Date -> MoveData -> InternalState
updateHourState (InternalState state) date moveData =
    let
        currentAngle =
            DateTimePicker.Geometry.calculateAngle originPoint axisPoint (Point moveData.offsetX moveData.offsetY)

        closestHour =
            hours
                |> Dict.toList
                |> List.map (\( hour, radians ) -> ( ( hour, radians ), abs (radians - currentAngle) ))
                |> List.sortBy Tuple.second
                |> List.head
                |> Maybe.map Tuple.first

        updateTime time hour =
            { time | hour = hour |> Maybe.andThen (String.toInt >> Result.toMaybe) }
    in
    InternalState
        { state
            | currentAngle =
                Maybe.map Tuple.second closestHour
            , time = updateTime state.time (Maybe.map Tuple.first closestHour)
        }


updateMinuteState : InternalState -> Maybe Date -> MoveData -> InternalState
updateMinuteState (InternalState state) date moveData =
    let
        currentAngle =
            DateTimePicker.Geometry.calculateAngle originPoint axisPoint (Point moveData.offsetX moveData.offsetY)

        closestMinute =
            minutes
                |> Dict.toList
                |> List.map (\( minute, radians ) -> ( ( minute, radians ), abs (radians - currentAngle) ))
                |> List.sortBy Tuple.second
                |> List.head
                |> Maybe.map Tuple.first

        updateTime time minute =
            { time | minute = minute |> Maybe.andThen (String.toInt >> Result.toMaybe) }
    in
    InternalState
        { state
            | currentAngle =
                Maybe.map Tuple.second closestMinute
            , time = updateTime state.time (Maybe.map Tuple.first closestMinute)
        }
