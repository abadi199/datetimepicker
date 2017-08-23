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
import DateTimePicker.Internal exposing (InternalState(..), Time)
import DateTimePicker.SharedStyles exposing (CssClasses(..), datepickerNamespace)
import Html exposing (Html, button, div, input, li, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (value)
import Html.Events exposing (onBlur, onClick, onFocus)
import MultiPanel
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
    DateTimePicker.Internal.initialState


{-| Initial state of the DatePicker with today Date
-}
initialStateWithToday : Date.Date -> State
initialStateWithToday today =
    DateTimePicker.Internal.initialStateWithToday today


{-| Initial Cmd to set the initial month to be displayed in the datepicker to the current month.
-}
initialCmd : (State -> Maybe Date.Date -> msg) -> State -> Cmd msg
initialCmd onChange (InternalState state) =
    let
        setDate now =
            InternalState
                { state
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
view pickerType attributes ((InternalState stateValue) as state) currentDate =
    let
        timeFormatter dateTimePickerConfig =
            dateTimePickerConfig.timeFormatter

        inputAttributes config =
            attributes
                ++ [ onFocus (datePickerFocused pickerType config state currentDate)
                   , onBlurWithChange
                        config.i18n.inputFormat.inputParser
                        (inputChangeHandler config state currentDate)
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
dialog pickerType (InternalState state) currentDate =
    let
        attributes config =
            [ onMouseDownPreventDefault <| config.onChange (InternalState { state | event = "dialog.onMouseDownPreventDefault" }) currentDate
            , class [ Dialog ]
            ]

        withTimeAttributes config timePickerType =
            case timePickerType of
                Analog ->
                    (onClick <| onChangeHandler pickerType (InternalState state) currentDate) :: attributes config

                Digital ->
                    attributes config
    in
    case pickerType of
        DateType config ->
            div (attributes config)
                [ DatePickerPanel.view
                    { onChange = config.onChange
                    , nameOfDays = config.nameOfDays
                    , firstDayOfWeek = config.firstDayOfWeek
                    , allowYearNavigation = config.allowYearNavigation
                    , titleFormatter = config.i18n.titleFormatter
                    , footerFormatter = config.i18n.footerFormatter
                    }
                    (InternalState state)
                    currentDate
                ]

        TimeType config ->
            let
                dialog =
                    case config.timePickerType of
                        Digital ->
                            TimePickerPanel.digital

                        Analog ->
                            TimePickerPanel.analog
            in
            div (withTimeAttributes config config.timePickerType)
                [ dialog
                    { onChange = config.onChange
                    , titleFormatter = config.i18n.timeTitleFormatter
                    }
                    (InternalState state)
                    currentDate
                ]

        DateTimeType config ->
            div (withTimeAttributes config config.timePickerType)
                (MultiPanel.view
                    { onChange = config.onChange
                    , nameOfDays = config.nameOfDays
                    , firstDayOfWeek = config.firstDayOfWeek
                    , allowYearNavigation = config.allowYearNavigation
                    , titleFormatter = config.i18n.titleFormatter
                    , footerFormatter = config.i18n.footerFormatter
                    }
                    ( config.timePickerType
                    , { onChange = config.onChange
                      , titleFormatter = config.i18n.timeTitleFormatter
                      }
                    )
                    (InternalState state)
                    currentDate
                )



-- EVENT HANDLERS


inputChangeHandler : Config a msg -> State -> Maybe Date.Date -> Maybe Date.Date -> msg
inputChangeHandler config (InternalState state) currentDate maybeDate =
    let
        (InternalState initialStateValue) =
            initialState
    in
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
                    { state
                        | date = Just date
                        , time = updateTime state.time
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
                            ( state.time
                            , state.activeTimeIndicator
                            , state.date
                            )

                updatedValue =
                    { state
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


datePickerFocused : Type msg -> Config a msg -> State -> Maybe Date.Date -> msg
datePickerFocused pickerType config (InternalState state) currentDate =
    let
        updatedTitleDate =
            case currentDate of
                Nothing ->
                    state.titleDate

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
            { state
                | inputFocused = True
                , event = "onFocus"
                , titleDate = updatedTitleDate
                , date = currentDate
                , forceClose = False
                , time = updateTime state.time
                , activeTimeIndicator =
                    case pickerType of
                        TimeType _ ->
                            Just DateTimePicker.Internal.HourIndicator

                        _ ->
                            Nothing
            }
        )
        currentDate


onChangeHandler : Type msg -> State -> Maybe Date.Date -> msg
onChangeHandler pickerType ((InternalState stateValue) as state) currentDate =
    let
        justDateHandler config =
            config.onChange state stateValue.date

        withTimeHandler config =
            case ( stateValue.date, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( Just date, Just hour, Just minute, Just amPm ) ->
                    config.onChange state <| Just <| DateTimePicker.DateUtils.setTime date hour minute amPm

                _ ->
                    config.onChange state Nothing
    in
    case pickerType of
        DateType config ->
            justDateHandler config

        DateTimeType config ->
            withTimeHandler config

        TimeType config ->
            withTimeHandler config
