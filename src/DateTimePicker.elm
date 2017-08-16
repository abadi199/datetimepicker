module DateTimePicker
    exposing
        ( State
        , datePicker
        , datePickerWithConfig
        , dateTimePicker
        , dateTimePickerWithConfig
        , initialCmd
        , initialState
        , initialStateWithToday
        , timePicker
        , timePickerWithConfig
        )

{-| DateTime Picker


# Picking date and time

@docs dateTimePicker, dateTimePickerWithConfig


# Picking dates

@docs datePicker, datePickerWithConfig


# Picking times

@docs timePicker, timePickerWithConfig


# Initial

@docs initialState, initialStateWithToday, initialCmd


# Internal State

@docs State

-}

import Date
import Date.Extra.Core
import DatePickerPanel
import DateTimePicker.Config exposing (Config, DatePickerConfig, TimePickerConfig, TimePickerType(..), Type(..), defaultDatePickerConfig, defaultDateTimePickerConfig, defaultTimePickerConfig)
import DateTimePicker.DateUtils
import DateTimePicker.Events exposing (onBlurWithChange, onMouseDownPreventDefault, onMouseUpPreventDefault, onTouchEndPreventDefault, onTouchStartPreventDefault)
import DateTimePicker.Internal exposing (InternalState(..), StateValue, Time, getStateValue, initialStateValue, initialStateValueWithToday)
import DateTimePicker.SharedStyles exposing (CssClasses(..), datepickerNamespace)
import Html exposing (Html, button, div, input, li, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (value)
import Html.Events exposing (onBlur, onClick, onFocus)
import Task
import TimePickerPanel


-- MODEL


{-| The state of the date time picker (for Internal Use)
-}
type alias State =
    InternalState


{-| Initial state of the DatePicker
-}
initialState : State
initialState =
    InternalState
        initialStateValue


{-| Initial state of the DatePicker with today Date
-}
initialStateWithToday : Date.Date -> State
initialStateWithToday today =
    InternalState
        (initialStateValueWithToday today)


{-| Initial Cmd to set the initial month to be displayed in the datepicker to the current month.
-}
initialCmd : (State -> Maybe Date.Date -> msg) -> State -> Cmd msg
initialCmd onChange state =
    let
        stateValue =
            getStateValue state

        setDate now =
            InternalState
                { stateValue
                    | today = Just now
                    , titleDate = Just <| Date.Extra.Core.toFirstOfMonth now
                }
    in
    Task.perform
        ((setDate >> onChange |> flip) Nothing)
        Date.now



-- VIEWS


{ id, class, classList } =
    datepickerNamespace


{-| Date Picker view function with default configuration.

Example:
type alias Model = { datePickerState : DateTimePicker.State, value : Maybe Date }

    type Msg
        = DatePickerChanged DateTimePicker.State (Maybe Date)

    view =
        DateTimePicker.datePicker
            DatePickerChanged
            [ class "my-datepicker" ]
            model.datePickerState
            model.value

-}
datePicker : (State -> Maybe Date.Date -> msg) -> List (Html.Attribute msg) -> State -> Maybe Date.Date -> Html msg
datePicker onChange =
    datePickerWithConfig (defaultDatePickerConfig onChange)


{-| Date Picker view function with custom configuration.

Example:
type alias Model = { datePickerState : DateTimePicker.State, value : Maybe Date }

    type Msg
        = DatePickerChanged DateTimePicker.State (Maybe Date)

    customConfig =
        let
            default =
                DateTimePicker.defaultConfig DatePickerChanged
        in
        { default
            | firstDayOfWeek = Date.Mon
            , autoClose = True
        }

    view =
        DateTimePicker.datePickerWithConfig
            customConfig
            DateTimePicker.defaultDatePickerConfig
            [ class "my-datepicker" ]
            model.datePickerState
            model.value

-}
datePickerWithConfig : Config (DatePickerConfig {}) msg -> List (Html.Attribute msg) -> State -> Maybe Date.Date -> Html msg
datePickerWithConfig config =
    view (DateType config)


{-| Date and Time Picker view with default configuration
Example:
type alias Model = { dateTimePickerState : DateTimePicker.State, value : Maybe DateType }

    type Msg
        = DatePickerChanged DateTimePicker.State (Maybe Date)

    view =
        DateTimePicker.dateTimePicker
            DatePickerChanged
            [ class "my-datetimepicker" ]
            model.dateTimePickerState
            model.value

-}
dateTimePicker : (State -> Maybe Date.Date -> msg) -> List (Html.Attribute msg) -> State -> Maybe Date.Date -> Html msg
dateTimePicker onChange =
    dateTimePickerWithConfig (defaultDateTimePickerConfig onChange)


{-| Time Picker view with default configuration
Example:
type alias Model = { timePickerState : DateTimePicker.State, value : Maybe DateType }

    type Msg
        = TimePickerChanged DateTimePicker.State (Maybe Date)

    view =
        DateTimePicker.timePicker
            TimePickerChanged
            [ class "my-timepicker" ]
            model.timePickerState
            model.value

-}
timePicker : (State -> Maybe Date.Date -> msg) -> List (Html.Attribute msg) -> State -> Maybe Date.Date -> Html msg
timePicker onChange =
    timePickerWithConfig (defaultTimePickerConfig onChange)


{-| Date and Time Picker view with custom configuration
Example:
type alias Model = { dateTimePickerState : DateTimePicker.State, value : Maybe Date }

    type Msg
        = DatePickerChanged DateTimePicker.State (Maybe Date)

    customConfig =
        let
            default =
                DateTimePicker.defaultDateTimePickerConfig DatePickerChanged
        in
        { default
            | firstDayOfWeek = Date.Mon
            , autoClose = True
        }

    view =
        DateTimePicker.dateTimePickerWithConfig
            customConfig
            [ class "my-datetimepicker" ]
            model.dateTimePickerState
            model.value

-}
dateTimePickerWithConfig : Config (DatePickerConfig TimePickerConfig) msg -> List (Html.Attribute msg) -> State -> Maybe Date.Date -> Html msg
dateTimePickerWithConfig config =
    view (DateTimeType config)


{-| Time Picker view with custom configuration
Example:
type alias Model = { timePickerState : DateTimePicker.State, value : Maybe Date }

    type Msg
        = TimePickerChanged DateTimePicker.State (Maybe Date)

    customConfig =
        let
            default =
                DateTimePicker.defaultTimePickerConfig TimePickerChanged
        in
        { default
            | autoClose = True
        }

    view =
        DateTimePicker.timePickerWithConfig
            customConfig
            [ class "my-datetimepicker" ]
            model.timePickerState
            model.value

-}
timePickerWithConfig : Config TimePickerConfig msg -> List (Html.Attribute msg) -> State -> Maybe Date.Date -> Html msg
timePickerWithConfig config =
    view (TimeType config)


view : Type msg -> List (Html.Attribute msg) -> State -> Maybe Date.Date -> Html msg
view pickerType attributes state currentDate =
    let
        stateValue =
            getStateValue state

        timeFormatter dateTimePickerConfig =
            dateTimePickerConfig.timeFormatter

        inputAttributes config =
            attributes
                ++ [ onFocus (datePickerFocused pickerType config stateValue currentDate)
                   , onBlurWithChange
                        config.i18n.inputFormat.inputParser
                        (inputChangeHandler config stateValue currentDate)
                   , currentDate
                        |> Maybe.map config.i18n.inputFormat.inputFormatter
                        |> Maybe.withDefault ""
                        |> value
                   ]

        shouldForceClose config =
            config.autoClose && stateValue.forceClose

        html config cssClasses =
            div
                (cssClasses :: config.attributes)
                [ input (inputAttributes config) []
                , if config.usePicker && stateValue.inputFocused && not (shouldForceClose config) then
                    dialog pickerType state currentDate
                  else
                    Html.text ""
                ]
    in
    case pickerType of
        DateType config ->
            html config (class [ DatePicker ])

        DateTimeType config ->
            html config (class [ DatePicker, TimePicker ])

        TimeType config ->
            html config (class [ TimePicker ])



-- VIEW HELPERSs


dialog : Type msg -> State -> Maybe Date.Date -> Html msg
dialog pickerType state currentDate =
    let
        stateValue =
            getStateValue state

        attributes config =
            [ onMouseDownPreventDefault <| config.onChange (InternalState { stateValue | event = "dialog.onMouseDownPreventDefault" }) currentDate
            , class [ Dialog ]
            ]

        withTimeAttributes config timePickerType =
            case timePickerType of
                Analog ->
                    (onClick <| onChangeHandler pickerType stateValue currentDate) :: attributes config

                Digital ->
                    attributes config
    in
    case pickerType of
        DateType datePickerConfig ->
            div (attributes datePickerConfig) [ datePickerDialog pickerType state currentDate ]

        TimeType timePickerConfig ->
            div (withTimeAttributes timePickerConfig timePickerConfig.timePickerType) [ timePickerDialog pickerType state currentDate ]

        DateTimeType timePickerConfig ->
            div (withTimeAttributes timePickerConfig timePickerConfig.timePickerType)
                [ datePickerDialog pickerType state currentDate
                , timePickerDialog pickerType state currentDate
                ]


datePickerDialog : Type msg -> State -> Maybe Date.Date -> Html msg
datePickerDialog pickerType state currentDate =
    case pickerType of
        DateType config ->
            DatePickerPanel.view
                { onChange = config.onChange
                , nameOfDays = config.nameOfDays
                , firstDayOfWeek = config.firstDayOfWeek
                , allowYearNavigation = config.allowYearNavigation
                , titleFormatter = config.i18n.titleFormatter
                , footerFormatter = config.i18n.footerFormatter
                , requiresTime = False
                }
                state
                currentDate

        DateTimeType config ->
            DatePickerPanel.view
                { onChange = config.onChange
                , nameOfDays = config.nameOfDays
                , firstDayOfWeek = config.firstDayOfWeek
                , allowYearNavigation = config.allowYearNavigation
                , titleFormatter = config.i18n.titleFormatter
                , footerFormatter = config.i18n.footerFormatter
                , requiresTime = True
                }
                state
                currentDate

        TimeType _ ->
            text ""


timePickerDialog : Type msg -> State -> Maybe Date.Date -> Html msg
timePickerDialog pickerType state currentDate =
    let
        panel timeType config =
            case timeType of
                Digital ->
                    TimePickerPanel.digital config state currentDate

                Analog ->
                    TimePickerPanel.analog config state currentDate
    in
    case pickerType of
        DateType _ ->
            text ""

        DateTimeType config ->
            panel config.timePickerType
                { onChange = config.onChange
                , titleFormatter = config.i18n.timeTitleFormatter
                , requiresDate = True
                }

        TimeType config ->
            panel config.timePickerType
                { onChange = config.onChange
                , titleFormatter = config.i18n.timeTitleFormatter
                , requiresDate = False
                }



-- EVENT HANDLERS


inputChangeHandler : Config a msg -> StateValue -> Maybe Date.Date -> Maybe Date.Date -> msg
inputChangeHandler config stateValue currentDate maybeDate =
    case maybeDate of
        Just date ->
            let
                updateTime time =
                    { time
                        | hour = Date.hour date |> DateTimePicker.DateUtils.fromMillitaryHour |> Just
                        , minute = Just (Date.minute date)
                        , amPm = Date.hour date |> DateTimePicker.DateUtils.fromMillitaryAmPm |> Just
                    }

                updatedValue =
                    { stateValue
                        | date = Just date
                        , time = updateTime stateValue.time
                        , inputFocused = False
                        , event = "inputChangeHandler"
                    }
            in
            config.onChange (InternalState updatedValue) maybeDate

        Nothing ->
            let
                ( updatedTime, updatedActiveTimeIndicator, updatedDate ) =
                    case currentDate of
                        Just _ ->
                            ( { hour = Nothing, minute = Nothing, amPm = Nothing }
                            , Just DateTimePicker.Internal.HourIndicator
                            , Nothing
                            )

                        Nothing ->
                            ( stateValue.time
                            , stateValue.activeTimeIndicator
                            , stateValue.date
                            )

                updatedValue =
                    { stateValue
                        | date = updatedDate
                        , time = updatedTime
                        , hourPickerStart = initialStateValue.hourPickerStart
                        , minutePickerStart = initialStateValue.minutePickerStart
                        , inputFocused = False
                        , event = "inputChangeHandler"
                        , activeTimeIndicator = updatedActiveTimeIndicator
                    }
            in
            config.onChange (InternalState updatedValue) maybeDate


datePickerFocused : Type msg -> Config a msg -> StateValue -> Maybe Date.Date -> msg
datePickerFocused pickerType config stateValue currentDate =
    let
        updatedTitleDate =
            case currentDate of
                Nothing ->
                    stateValue.titleDate

                Just _ ->
                    currentDate

        updateTime time =
            { time
                | hour = currentDate |> Maybe.map (Date.hour >> DateTimePicker.DateUtils.fromMillitaryHour)
                , minute = currentDate |> Maybe.map Date.minute
                , amPm = currentDate |> Maybe.map (Date.hour >> DateTimePicker.DateUtils.fromMillitaryAmPm)
            }
    in
    config.onChange
        (InternalState
            { stateValue
                | inputFocused = True
                , event = "onFocus"
                , titleDate = updatedTitleDate
                , date = currentDate
                , forceClose = False
                , time = updateTime stateValue.time
                , activeTimeIndicator =
                    case pickerType of
                        TimeType _ ->
                            Just DateTimePicker.Internal.HourIndicator

                        _ ->
                            Nothing
            }
        )
        currentDate


onChangeHandler : Type msg -> StateValue -> Maybe Date.Date -> msg
onChangeHandler pickerType stateValue currentDate =
    let
        justDateHandler config =
            config.onChange (InternalState stateValue) stateValue.date

        withTimeHandler config =
            case ( stateValue.date, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( Just date, Just hour, Just minute, Just amPm ) ->
                    config.onChange (InternalState stateValue) <| Just <| DateTimePicker.DateUtils.setTime date hour minute amPm

                _ ->
                    config.onChange (InternalState stateValue) Nothing
    in
    case pickerType of
        DateType config ->
            justDateHandler config

        DateTimeType config ->
            withTimeHandler config

        TimeType config ->
            withTimeHandler config
