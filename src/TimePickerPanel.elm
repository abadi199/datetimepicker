module TimePickerPanel exposing (Config, analog, digital)

import Date exposing (Date)
import DateTimePicker.AnalogClock
import DateTimePicker.ClockUtils
import DateTimePicker.DateUtils
import DateTimePicker.Events exposing (onBlurWithChange, onMouseDownPreventDefault, onMouseUpPreventDefault, onTouchEndPreventDefault, onTouchStartPreventDefault)
import DateTimePicker.Helpers exposing (Type(..), updateCurrentDate, updateTimeIndicator)
import DateTimePicker.Internal exposing (InternalState(..), Time)
import DateTimePicker.SharedStyles exposing (CssClasses(..), datepickerNamespace)
import DateTimePicker.Svg
import Html exposing (Html, button, div, input, li, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes
import String


-- MODEL


{-| The state of the date time picker (for Internal Use)
-}
type alias State =
    InternalState


type alias Config msg =
    { onChange : State -> Maybe Date -> msg
    , titleFormatter : Date -> String
    }



-- VIEWS


{ id, class, classList } =
    datepickerNamespace


digital : Config msg -> State -> Maybe Date.Date -> Html msg
digital config ((InternalState stateValue) as state) currentDate =
    let
        toListItem str =
            li [] [ text str ]

        hours =
            List.range stateValue.hourPickerStart (stateValue.hourPickerStart + 6)

        minutes =
            List.range stateValue.minutePickerStart (stateValue.minutePickerStart + 6)

        ampmList =
            [ "AM", "PM" ]

        timeSelector =
            List.map3 toRow hours minutes (ampmList ++ List.repeat 4 "")

        toRow hour min ampm =
            tr []
                [ hourCell hour
                , minuteCell min
                , amPmCell ampm
                ]

        hourCell hour =
            td
                [ onMouseDownPreventDefault <| hourClickHandler config state hour
                , onTouchStartPreventDefault <| hourClickHandler config state hour
                , stateValue.time.hour
                    |> Maybe.map ((==) hour)
                    |> Maybe.map
                        (\selected ->
                            if selected then
                                class [ SelectedHour ]
                            else
                                class []
                        )
                    |> Maybe.withDefault (class [])
                , Html.Attributes.attribute "role" "button"
                , Html.Attributes.attribute "aria-label" ("hour " ++ toString hour)
                ]
                [ text <| (toString >> DateTimePicker.DateUtils.padding) hour ]

        minuteCell min =
            td
                [ onMouseDownPreventDefault <| minuteClickHandler config state min
                , onTouchStartPreventDefault <| minuteClickHandler config state min
                , stateValue.time.minute
                    |> Maybe.map ((==) min)
                    |> Maybe.map
                        (\selected ->
                            if selected then
                                class [ SelectedMinute ]
                            else
                                class []
                        )
                    |> Maybe.withDefault (class [])
                , Html.Attributes.attribute "role" "button"
                , Html.Attributes.attribute "aria-label" ("minute " ++ toString min)
                ]
                [ text <| (toString >> DateTimePicker.DateUtils.padding) min ]

        amPmCell ampm =
            let
                defaultClasses =
                    class <|
                        if ampm == "" then
                            [ EmptyCell ]
                        else
                            []
            in
            td
                ([ stateValue.time.amPm
                    |> Maybe.map ((==) ampm)
                    |> Maybe.map
                        (\selected ->
                            if selected then
                                class [ SelectedAmPm ]
                            else
                                defaultClasses
                        )
                    |> Maybe.withDefault defaultClasses
                 , Html.Attributes.attribute "role" "button"
                 , Html.Attributes.attribute "aria-label" ampm
                 ]
                    ++ (if ampm == "" then
                            []
                        else
                            [ onMouseDownPreventDefault <| amPmClickHandler config state ampm
                            , onTouchStartPreventDefault <| amPmClickHandler config state ampm
                            ]
                       )
                )
                [ text ampm ]

        upArrows config =
            [ tr [ class [ ArrowUp ] ]
                [ td
                    [ onMouseDownPreventDefault <| hourUpHandler config state currentDate
                    , onTouchStartPreventDefault <| hourUpHandler config state currentDate
                    ]
                    [ DateTimePicker.Svg.upArrow ]
                , td
                    [ onMouseDownPreventDefault <| minuteUpHandler config state currentDate
                    , onTouchStartPreventDefault <| minuteUpHandler config state currentDate
                    ]
                    [ DateTimePicker.Svg.upArrow ]
                , td [] []
                ]
            ]

        downArrows config =
            [ tr [ class [ ArrowDown ] ]
                [ td
                    [ onMouseDownPreventDefault <| hourDownHandler config state currentDate
                    , onTouchStartPreventDefault <| hourDownHandler config state currentDate
                    ]
                    [ DateTimePicker.Svg.downArrow ]
                , td
                    [ onMouseDownPreventDefault <| minuteDownHandler config state currentDate
                    , onTouchStartPreventDefault <| minuteDownHandler config state currentDate
                    ]
                    [ DateTimePicker.Svg.downArrow ]
                , td [] []
                ]
            ]
    in
    div [ class [ TimePickerDialog, DigitalTime ] ]
        [ div [ class [ Header ] ]
            [ Maybe.map config.titleFormatter currentDate |> Maybe.withDefault "-- : --" |> text ]
        , div [ class [ Body ] ]
            [ table []
                [ tbody []
                    (upArrows config
                        ++ timeSelector
                        ++ downArrows config
                    )
                ]
            ]
        ]


analog : Config msg -> State -> Maybe Date.Date -> Html msg
analog config ((InternalState stateValue) as state) currentDate =
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
                    [ text "AM" ]
                , div
                    [ onMouseDownPreventDefault <| amPmPickerHandler config state currentDate "PM"
                    , onTouchStartPreventDefault <| amPmPickerHandler config state currentDate "PM"
                    , case stateValue.time.amPm of
                        Just "PM" ->
                            class [ PM, SelectedAmPm ]

                        _ ->
                            class [ PM ]
                    ]
                    [ text "PM" ]
                ]
    in
    div [ class [ TimePickerDialog, AnalogTime ] ]
        [ div [ class [ Header ] ]
            [ span
                [ onMouseDownPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.HourIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.HourIndicator)
                , class (Hour :: isActive DateTimePicker.Internal.HourIndicator)
                ]
                [ text (stateValue.time.hour |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
            , span [ class [ Separator ] ] [ text " : " ]
            , span
                [ onMouseDownPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.MinuteIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.MinuteIndicator)
                , class (Minute :: isActive DateTimePicker.Internal.MinuteIndicator)
                ]
                [ text (stateValue.time.minute |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
            , span
                [ onMouseDownPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.AMPMIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config state currentDate DateTimePicker.Internal.AMPMIndicator)
                , class (AMPM :: isActive DateTimePicker.Internal.AMPMIndicator)
                ]
                [ text (stateValue.time.amPm |> Maybe.withDefault "--") ]
            ]
        , div [ class [ Body ] ]
            [ case stateValue.activeTimeIndicator of
                Just DateTimePicker.Internal.AMPMIndicator ->
                    amPmPicker config

                _ ->
                    DateTimePicker.AnalogClock.clock config.onChange state currentDate
            ]
        ]


hourClickHandler : Config msg -> State -> Int -> msg
hourClickHandler config (InternalState state) hour =
    let
        time =
            state.time

        updatedStateValue =
            { state | time = { time | hour = Just hour }, event = "hourClickHandler" }

        ( updatedTime, forceClose ) =
            case ( updatedStateValue.time.minute, updatedStateValue.time.amPm ) of
                ( Just minute, Just amPm ) ->
                    ( Just <| DateTimePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )
    in
    config.onChange (InternalState { updatedStateValue | forceClose = forceClose }) updatedTime


minuteClickHandler : Config msg -> State -> Int -> msg
minuteClickHandler config (InternalState state) minute =
    let
        time =
            state.time

        updatedStateValue =
            { state | time = { time | minute = Just minute }, event = "minuteClickHandler" }

        ( updatedTime, forceClose ) =
            case ( updatedStateValue.time.hour, updatedStateValue.time.amPm ) of
                ( Just hour, Just amPm ) ->
                    ( Just <| DateTimePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )
    in
    config.onChange (InternalState { updatedStateValue | forceClose = forceClose }) updatedTime


amPmClickHandler : Config msg -> State -> String -> msg
amPmClickHandler config (InternalState state) amPm =
    let
        time =
            state.time

        updatedStateValue =
            { state
                | time =
                    { time
                        | amPm =
                            if String.isEmpty amPm then
                                Nothing
                            else
                                Just amPm
                    }
                , event = "amPmClickHandler"
            }

        ( updatedTime, forceClose ) =
            case ( updatedStateValue.time.hour, updatedStateValue.time.minute ) of
                ( Just hour, Just minute ) ->
                    ( Just <| DateTimePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )
    in
    config.onChange (InternalState { updatedStateValue | forceClose = forceClose }) updatedTime


hourUpHandler : Config msg -> State -> Maybe Date.Date -> msg
hourUpHandler config (InternalState state) currentDate =
    let
        updatedState =
            if state.hourPickerStart - 6 >= 1 then
                { state | hourPickerStart = state.hourPickerStart - 6 }
            else
                state
    in
    config.onChange (InternalState updatedState) currentDate


hourDownHandler : Config msg -> State -> Maybe Date.Date -> msg
hourDownHandler config (InternalState state) currentDate =
    let
        updatedState =
            if state.hourPickerStart + 6 <= 12 then
                { state | hourPickerStart = state.hourPickerStart + 6 }
            else
                state
    in
    config.onChange (InternalState updatedState) currentDate


minuteUpHandler : Config msg -> State -> Maybe Date.Date -> msg
minuteUpHandler config (InternalState state) currentDate =
    let
        updatedState =
            if state.minutePickerStart - 6 >= 0 then
                { state | minutePickerStart = state.minutePickerStart - 6 }
            else
                state
    in
    config.onChange (InternalState updatedState) currentDate


minuteDownHandler : Config msg -> State -> Maybe Date.Date -> msg
minuteDownHandler config (InternalState state) currentDate =
    let
        updatedState =
            if state.minutePickerStart + 6 <= 59 then
                { state | minutePickerStart = state.minutePickerStart + 6 }
            else
                state
    in
    config.onChange (InternalState updatedState) currentDate


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


amPmIndicatorHandler : Config msg -> State -> Maybe Date.Date -> msg
amPmIndicatorHandler config (InternalState state) currentDate =
    let
        updateTime time =
            case time.amPm of
                Just "AM" ->
                    { time | amPm = Just "PM" }

                Just "PM" ->
                    { time | amPm = Just "AM" }

                _ ->
                    { time | amPm = Just "AM" }

        updatedState =
            { state
                | activeTimeIndicator = Just DateTimePicker.Internal.AMPMIndicator
                , time = updateTime state.time
            }
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
        (updateCurrentDate TimeType updatedState)
