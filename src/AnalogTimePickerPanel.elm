module AnalogTimePickerPanel exposing (view)

import Date exposing (Date)
import DateTimePicker.ClockUtils exposing (hours, minutes, minutesPerFive)
import DateTimePicker.DateUtils
import DateTimePicker.Events exposing (MoveData, onBlurWithChange, onMouseDownPreventDefault, onMouseMoveWithPosition, onMouseUpPreventDefault, onPointerMoveWithPosition, onPointerUp, onTouchEndPreventDefault, onTouchMovePreventDefault, onTouchStartPreventDefault)
import DateTimePicker.Geometry exposing (Point)
import DateTimePicker.Internal exposing (InternalState(..), Time, TimeIndicator(..))
import DateTimePicker.SharedStyles exposing (CssClasses(..), datepickerNamespace)
import Dict
import Html exposing (Html, button, div, input, li, span, table, tbody, td, text, th, thead, tr, ul)
import Json.Decode
import String
import Svg exposing (Svg, circle, g, line, svg, text, text_)
import Svg.Attributes exposing (cx, cy, fill, height, r, stroke, strokeWidth, textAnchor, viewBox, width, x, x1, x2, y, y1, y2)


{-| The state of the date time picker (for Internal Use)
-}
type alias State =
    InternalState


type alias Config msg =
    { onChange : State -> Maybe Date -> msg
    , titleFormatter : Date -> String
    }


view : Config msg -> State -> Maybe Date.Date -> Html msg
view config ((InternalState stateValue) as state) currentDate =
    let
        isActive timeIndicator =
            if stateValue.activeTimeIndicator == Just timeIndicator then
                [ Active ]
            else
                []

        amPmPicker config =
            div [ class [ AMPMPicker ] ]
                [ div
                    [ onMouseDownPreventDefault <| amPmPickerHandler config state currentDate "AM"
                    , onTouchStartPreventDefault <| amPmPickerHandler config state currentDate "AM"
                    , case stateValue.time.amPm of
                        Just "AM" ->
                            class [ AM, SelectedAmPm ]

                        _ ->
                            class [ AM ]
                    ]
                    [ Html.text "AM" ]
                , div
                    [ onMouseDownPreventDefault <| amPmPickerHandler config state currentDate "PM"
                    , onTouchStartPreventDefault <| amPmPickerHandler config state currentDate "PM"
                    , case stateValue.time.amPm of
                        Just "PM" ->
                            class [ PM, SelectedAmPm ]

                        _ ->
                            class [ PM ]
                    ]
                    [ Html.text "PM" ]
                ]
    in
    div [ class [ TimePickerDialog, AnalogTime ] ]
        [ div [ class [ Header ] ]
            [ span
                [ onMouseDownPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.HourIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.HourIndicator)
                , class (Hour :: isActive DateTimePicker.Internal.HourIndicator)
                ]
                [ Html.text (stateValue.time.hour |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
            , span [ class [ Separator ] ] [ Html.text " : " ]
            , span
                [ onMouseDownPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.MinuteIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.MinuteIndicator)
                , class (Minute :: isActive DateTimePicker.Internal.MinuteIndicator)
                ]
                [ Html.text (stateValue.time.minute |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
            , span
                [ onMouseDownPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.AMPMIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.AMPMIndicator)
                , class (AMPM :: isActive DateTimePicker.Internal.AMPMIndicator)
                ]
                [ Html.text (stateValue.time.amPm |> Maybe.withDefault "--") ]
            ]
        , div [ class [ Body ] ]
            [ case stateValue.activeTimeIndicator of
                Just DateTimePicker.Internal.AMPMIndicator ->
                    amPmPicker config

                _ ->
                    clock config.onChange state currentDate
            ]
        ]


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
                |> Maybe.withDefault (Html.text "")

        drawMinute minute =
            Dict.get (toString minute) minutes
                |> Maybe.map (DateTimePicker.Geometry.calculateArrowPoint originPoint minuteArrowLength >> drawArrow onChange (InternalState state) date)
                |> Maybe.withDefault (Html.text "")
    in
    case ( state.activeTimeIndicator, time.hour, time.minute, time.amPm ) of
        ( Nothing, Just hour, Just minute, Just _ ) ->
            g [] [ drawHour hour minute, drawMinute minute ]

        _ ->
            Html.text ""


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
        [ Html.text number ]


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
            Html.text ""

        Just angle ->
            if shouldDrawArrow then
                angle
                    |> arrowPoint
                    |> drawArrow onChange (InternalState state) date
            else
                Html.text ""


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
            updateCurrentDate (InternalState state)

        updatedState =
            InternalState
                { state
                    | activeTimeIndicator =
                        updateTimeIndicator state.activeTimeIndicator state.time
                }
    in
    onChange updatedState updatedDate


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


timeIndicatorHandler : Config msg -> State -> Maybe Date.Date -> DateTimePicker.Internal.TimeIndicator -> msg
timeIndicatorHandler config (InternalState state) currentDate timeIndicator =
    let
        updatedState =
            { state
                | activeTimeIndicator = updatedActiveTimeIndicator
                , currentAngle = currentAngle
            }

        updatedActiveTimeIndicator =
            if state.activeTimeIndicator == Just timeIndicator then
                Nothing
            else
                Just timeIndicator

        currentAngle =
            case ( timeIndicator, state.time.hour, state.time.minute ) of
                ( DateTimePicker.Internal.HourIndicator, Just hour, _ ) ->
                    DateTimePicker.ClockUtils.hourToAngle hour

                ( DateTimePicker.Internal.MinuteIndicator, _, Just minute ) ->
                    DateTimePicker.ClockUtils.minuteToAngle minute

                ( _, _, _ ) ->
                    Nothing
    in
    config.onChange (InternalState updatedState) currentDate


amPmPickerHandler : Config msg -> State -> Maybe Date.Date -> String -> msg
amPmPickerHandler config (InternalState state) currentDate amPm =
    let
        time =
            state.time

        updatedTime =
            { time | amPm = Just amPm }

        updatedState =
            InternalState
                { state
                    | time = updatedTime
                    , activeTimeIndicator =
                        updateTimeIndicator state.activeTimeIndicator updatedTime
                }
    in
    config.onChange
        updatedState
        (updateCurrentDate updatedState)


updateCurrentDate : InternalState -> Maybe Date
updateCurrentDate (InternalState state) =
    case ( state.time.hour, state.time.minute, state.time.amPm ) of
        ( Just hour, Just minute, Just amPm ) ->
            Just (DateTimePicker.DateUtils.toTime hour minute amPm)

        _ ->
            Nothing


updateTimeIndicator : Maybe TimeIndicator -> Time -> Maybe TimeIndicator
updateTimeIndicator activeIndicator time =
    case ( activeIndicator, time.hour, time.minute, time.amPm ) of
        ( Just HourIndicator, _, Nothing, _ ) ->
            Just MinuteIndicator

        ( Just HourIndicator, _, Just _, Nothing ) ->
            Just AMPMIndicator

        ( Just HourIndicator, _, Just _, Just _ ) ->
            Nothing

        ( Just MinuteIndicator, _, _, Nothing ) ->
            Just AMPMIndicator

        ( Just MinuteIndicator, Nothing, _, Just _ ) ->
            Just HourIndicator

        ( Just MinuteIndicator, Just _, _, Just _ ) ->
            Nothing

        ( Just AMPMIndicator, Nothing, _, _ ) ->
            Just HourIndicator

        ( Just AMPMIndicator, Just _, Nothing, _ ) ->
            Just MinuteIndicator

        ( Just AMPMIndicator, Just _, Just _, _ ) ->
            Nothing

        ( Nothing, Nothing, _, _ ) ->
            Just HourIndicator

        ( Nothing, Just _, Nothing, _ ) ->
            Just MinuteIndicator

        ( Nothing, Just _, Just _, Nothing ) ->
            Just AMPMIndicator

        ( _, Just _, Just _, Just _ ) ->
            Nothing
