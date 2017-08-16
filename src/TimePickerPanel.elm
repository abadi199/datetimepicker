module TimePickerPanel exposing (Config, analog, digital)

import Date exposing (Date)
import DateTimePicker.AnalogClock
import DateTimePicker.ClockUtils
import DateTimePicker.DateUtils
import DateTimePicker.Events exposing (onBlurWithChange, onMouseDownPreventDefault, onMouseUpPreventDefault, onTouchEndPreventDefault, onTouchStartPreventDefault)
import DateTimePicker.Helpers exposing (Type(..), updateCurrentDate, updateTimeIndicator)
import DateTimePicker.Internal exposing (InternalState(..), StateValue, Time, getStateValue, initialStateValue, initialStateValueWithToday)
import DateTimePicker.SharedStyles exposing (CssClasses(..), datepickerNamespace)
import DateTimePicker.Svg
import Html exposing (Html, button, div, input, li, span, table, tbody, td, text, th, thead, tr, ul)
import String


-- MODEL


{-| The state of the date time picker (for Internal Use)
-}
type alias State =
    InternalState


type alias Config msg =
    { onChange : State -> Maybe Date -> msg
    , titleFormatter : Date -> String
    , requiresDate : Bool
    }



-- VIEWS


{ id, class, classList } =
    datepickerNamespace


digital : Config msg -> State -> Maybe Date.Date -> Html msg
digital config state currentDate =
    let
        stateValue =
            getStateValue state

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
                [ onMouseDownPreventDefault <| hourClickHandler config stateValue hour
                , onTouchStartPreventDefault <| hourClickHandler config stateValue hour
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
                ]
                [ text <| (toString >> DateTimePicker.DateUtils.padding) hour ]

        minuteCell min =
            td
                [ onMouseDownPreventDefault <| minuteClickHandler config stateValue min
                , onTouchStartPreventDefault <| minuteClickHandler config stateValue min
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
                 ]
                    ++ (if ampm == "" then
                            []
                        else
                            [ onMouseDownPreventDefault <| amPmClickHandler config stateValue ampm
                            , onTouchStartPreventDefault <| amPmClickHandler config stateValue ampm
                            ]
                       )
                )
                [ text ampm ]

        upArrows config =
            [ tr [ class [ ArrowUp ] ]
                [ td
                    [ onMouseDownPreventDefault <| hourUpHandler config stateValue currentDate
                    , onTouchStartPreventDefault <| hourUpHandler config stateValue currentDate
                    ]
                    [ DateTimePicker.Svg.upArrow ]
                , td
                    [ onMouseDownPreventDefault <| minuteUpHandler config stateValue currentDate
                    , onTouchStartPreventDefault <| minuteUpHandler config stateValue currentDate
                    ]
                    [ DateTimePicker.Svg.upArrow ]
                , td [] []
                ]
            ]

        downArrows config =
            [ tr [ class [ ArrowDown ] ]
                [ td
                    [ onMouseDownPreventDefault <| hourDownHandler config stateValue currentDate
                    , onTouchStartPreventDefault <| hourDownHandler config stateValue currentDate
                    ]
                    [ DateTimePicker.Svg.downArrow ]
                , td
                    [ onMouseDownPreventDefault <| minuteDownHandler config stateValue currentDate
                    , onTouchStartPreventDefault <| minuteDownHandler config stateValue currentDate
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
analog config state currentDate =
    let
        stateValue =
            getStateValue state

        isActive timeIndicator =
            if stateValue.activeTimeIndicator == Just timeIndicator then
                [ Active ]
            else
                []

        amPmPicker config =
            div [ class [ AMPMPicker ] ]
                [ div
                    [ onMouseDownPreventDefault <| amPmPickerHandler config stateValue currentDate "AM"
                    , onTouchStartPreventDefault <| amPmPickerHandler config stateValue currentDate "AM"
                    , case stateValue.time.amPm of
                        Just "AM" ->
                            class [ AM, SelectedAmPm ]

                        _ ->
                            class [ AM ]
                    ]
                    [ text "AM" ]
                , div
                    [ onMouseDownPreventDefault <| amPmPickerHandler config stateValue currentDate "PM"
                    , onTouchStartPreventDefault <| amPmPickerHandler config stateValue currentDate "PM"
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
                [ onMouseDownPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.Internal.HourIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.Internal.HourIndicator)
                , class (Hour :: isActive DateTimePicker.Internal.HourIndicator)
                ]
                [ text (stateValue.time.hour |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
            , span [ class [ Separator ] ] [ text " : " ]
            , span
                [ onMouseDownPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.Internal.MinuteIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.Internal.MinuteIndicator)
                , class (Minute :: isActive DateTimePicker.Internal.MinuteIndicator)
                ]
                [ text (stateValue.time.minute |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
            , span
                [ onMouseDownPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.Internal.AMPMIndicator)
                , onTouchStartPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.Internal.AMPMIndicator)
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


hourClickHandler : Config msg -> StateValue -> Int -> msg
hourClickHandler config stateValue hour =
    let
        time =
            stateValue.time

        updatedStateValue =
            { stateValue | time = { time | hour = Just hour }, event = "hourClickHandler" }

        ( updatedDate, forceCloseWithDate ) =
            case ( stateValue.time.minute, stateValue.time.amPm, stateValue.date ) of
                ( Just minute, Just amPm, Just date ) ->
                    ( Just <| DateTimePicker.DateUtils.setTime date hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        ( updatedTime, forceCloseTimeOnly ) =
            case ( updatedStateValue.time.minute, updatedStateValue.time.amPm ) of
                ( Just minute, Just amPm ) ->
                    ( Just <| DateTimePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        withDateHandler config =
            config.onChange (InternalState { updatedStateValue | forceClose = forceCloseWithDate }) updatedDate

        justTimeHandler config =
            config.onChange (InternalState { updatedStateValue | forceClose = forceCloseTimeOnly }) updatedTime
    in
    if config.requiresDate then
        withDateHandler config
    else
        justTimeHandler config


minuteClickHandler : Config msg -> StateValue -> Int -> msg
minuteClickHandler config stateValue minute =
    let
        time =
            stateValue.time

        updatedStateValue =
            { stateValue | time = { time | minute = Just minute }, event = "minuteClickHandler" }

        ( updatedDate, forceCloseWithDate ) =
            case ( stateValue.time.hour, stateValue.time.amPm, stateValue.date ) of
                ( Just hour, Just amPm, Just date ) ->
                    ( Just <| DateTimePicker.DateUtils.setTime date hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        ( updatedTime, forceCloseTimeOnly ) =
            case ( updatedStateValue.time.hour, updatedStateValue.time.amPm ) of
                ( Just hour, Just amPm ) ->
                    ( Just <| DateTimePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        withDateHandler config =
            config.onChange (InternalState { updatedStateValue | forceClose = forceCloseWithDate }) updatedDate

        justTimeHandler config =
            config.onChange (InternalState { updatedStateValue | forceClose = forceCloseTimeOnly }) updatedTime
    in
    if config.requiresDate then
        withDateHandler config
    else
        justTimeHandler config


amPmClickHandler : Config msg -> StateValue -> String -> msg
amPmClickHandler config stateValue amPm =
    let
        time =
            stateValue.time

        updatedStateValue =
            { stateValue
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

        ( updatedDate, forceCloseWithDate ) =
            case ( stateValue.time.hour, stateValue.time.minute, stateValue.date ) of
                ( Just hour, Just minute, Just date ) ->
                    ( Just <| DateTimePicker.DateUtils.setTime date hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        ( updatedTime, forceCloseTimeOnly ) =
            case ( updatedStateValue.time.hour, updatedStateValue.time.minute ) of
                ( Just hour, Just minute ) ->
                    ( Just <| DateTimePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        withDateHandler config =
            config.onChange (InternalState { updatedStateValue | forceClose = forceCloseWithDate }) updatedDate

        justTimeHandler config =
            config.onChange (InternalState { updatedStateValue | forceClose = forceCloseTimeOnly }) updatedTime
    in
    if config.requiresDate then
        withDateHandler config
    else
        justTimeHandler config


hourUpHandler : Config msg -> StateValue -> Maybe Date.Date -> msg
hourUpHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.hourPickerStart - 6 >= 1 then
                { stateValue | hourPickerStart = stateValue.hourPickerStart - 6 }
            else
                stateValue
    in
    config.onChange (InternalState updatedState) currentDate


hourDownHandler : Config msg -> StateValue -> Maybe Date.Date -> msg
hourDownHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.hourPickerStart + 6 <= 12 then
                { stateValue | hourPickerStart = stateValue.hourPickerStart + 6 }
            else
                stateValue
    in
    config.onChange (InternalState updatedState) currentDate


minuteUpHandler : Config msg -> StateValue -> Maybe Date.Date -> msg
minuteUpHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.minutePickerStart - 6 >= 0 then
                { stateValue | minutePickerStart = stateValue.minutePickerStart - 6 }
            else
                stateValue
    in
    config.onChange (InternalState updatedState) currentDate


minuteDownHandler : Config msg -> StateValue -> Maybe Date.Date -> msg
minuteDownHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.minutePickerStart + 6 <= 59 then
                { stateValue | minutePickerStart = stateValue.minutePickerStart + 6 }
            else
                stateValue
    in
    config.onChange (InternalState updatedState) currentDate


timeIndicatorHandler : Config msg -> StateValue -> Maybe Date.Date -> DateTimePicker.Internal.TimeIndicator -> msg
timeIndicatorHandler config stateValue currentDate timeIndicator =
    let
        updatedState =
            { stateValue
                | activeTimeIndicator = updatedActiveTimeIndicator
                , currentAngle = currentAngle
            }

        updatedActiveTimeIndicator =
            if stateValue.activeTimeIndicator == Just timeIndicator then
                Nothing
            else
                Just timeIndicator

        currentAngle =
            case ( timeIndicator, stateValue.time.hour, stateValue.time.minute ) of
                ( DateTimePicker.Internal.HourIndicator, Just hour, _ ) ->
                    DateTimePicker.ClockUtils.hourToAngle hour

                ( DateTimePicker.Internal.MinuteIndicator, _, Just minute ) ->
                    DateTimePicker.ClockUtils.minuteToAngle minute

                ( _, _, _ ) ->
                    Nothing
    in
    config.onChange (InternalState updatedState) currentDate


amPmIndicatorHandler : Config msg -> StateValue -> Maybe Date.Date -> msg
amPmIndicatorHandler config stateValue currentDate =
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
            { stateValue
                | activeTimeIndicator = Just DateTimePicker.Internal.AMPMIndicator
                , time = updateTime stateValue.time
            }
    in
    config.onChange (InternalState updatedState) currentDate


amPmPickerHandler : Config msg -> StateValue -> Maybe Date.Date -> String -> msg
amPmPickerHandler config stateValue currentDate amPm =
    let
        time =
            stateValue.time

        updatedTime =
            { time | amPm = Just amPm }

        updatedState =
            { stateValue | time = updatedTime }
                |> updateTimeIndicator
    in
    config.onChange
        (InternalState updatedState)
        (updateCurrentDate TimeType updatedState)
