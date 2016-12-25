module DateTimePicker
    exposing
        ( Config
        , DatePickerConfig
        , TimePickerConfig
        , TimePickerType(..)
        , NameOfDays
        , State
        , datePicker
        , datePickerWithConfig
        , dateTimePicker
        , dateTimePickerWithConfig
          -- , timePickerWithConfig
        , defaultDatePickerConfig
        , defaultTimePickerConfig
        , defaultDateTimePickerConfig
        , initialState
        , initialStateWithToday
        , initialCmd
        )

{-| DatePicker

# Configuration
@docs Config, DatePickerConfig, TimePickerConfig, defaultDatePickerConfig, defaultTimePickerConfig, defaultDateTimePickerConfig, NameOfDays, TimePickerType

# View
@docs datePicker, datePickerWithConfig, dateTimePicker, dateTimePickerWithConfig

# Initial
@docs initialState, initialStateWithToday, initialCmd

# Internal State
@docs State

-}

import Date exposing (Date)
import Html exposing (Html, input, div, span, text, button, table, tr, td, th, thead, tbody, ul, li)
import Html.Attributes exposing (value)
import Html.Events exposing (onFocus, onBlur, onClick)
import Task
import DateTimePicker.Formatter
import DateTimePicker.Svg
import DateTimePicker.DateUtils
import DateTimePicker.AnalogClock
import DateTimePicker.State exposing (InternalState(..), StateValue, Time, getStateValue, initialStateValue, initialStateValueWithToday)
import Date.Extra.Core
import Date.Extra.Duration
import List.Extra
import DateTimePicker.SharedStyles exposing (datepickerNamespace, CssClasses(..))
import String
import DateTimePicker.Events exposing (onMouseDownPreventDefault, onMouseUpPreventDefault, onBlurWithChange)


-- MODEL


{-| Configuration

 * `onChange` is the message for when the selected value and internal `State` in the date picker has changed.
 * `dateFormatter` is a Date to string formatter used to display the date in the input text
 * `dateTimeFormatter` is a Date to string formatter used to display the date in the footer section.
 * `autoClose` is a flag to indicate whether the dialog should be automatically closed when a date and/or time is selected.
-}
type alias Config otherConfig msg =
    { otherConfig
        | onChange : State -> Maybe Date -> msg
        , dateFormatter : Date -> String
        , dateTimeFormatter : Date -> String
        , autoClose : Bool
    }


{-| Configuration for the DatePicker

 * `nameOfDays` is the configuration for name of days in a week.
 * `firstDayOfWeek` is the first day of the week.
 * `formatter` is the Date to String formatter for the input value.
 * `titleFormatter` is the Date to String formatter for the dialog's title.
 * `fullDateFormatter` is the Date to String formatter for the dialog's footer.

-}
type alias DatePickerConfig otherConfig =
    { otherConfig
        | nameOfDays : NameOfDays
        , firstDayOfWeek : Date.Day
        , titleFormatter : Date -> String
        , fullDateFormatter : Date -> String
    }


{-| Default configuration for DatePicker

 * `onChange` No Default
 * `dateFormatter` Default: `"%m/%d/%Y"`
 * `dateTimeFormatter` Default: `"%m/%d/%Y %I:%M %p"`
 * `autoClose` Default: True
 * `nameOfDays` see `NameOfDays` for the default values.
 * `firstDayOfWeek` Default: Sunday.
 * `titleFormatter`  Default: `"%B %Y"`
 * `fullDateFormatter` Default:  `"%A, %B %d, %Y"`
-}
defaultDatePickerConfig : (State -> Maybe Date -> msg) -> Config (DatePickerConfig {}) msg
defaultDatePickerConfig onChange =
    { onChange = onChange
    , dateFormatter = DateTimePicker.Formatter.dateFormatter
    , dateTimeFormatter = DateTimePicker.Formatter.dateTimeFormatter
    , autoClose = True
    , nameOfDays = defaultNameOfDays
    , firstDayOfWeek = Date.Sun
    , titleFormatter = DateTimePicker.Formatter.titleFormatter
    , fullDateFormatter = DateTimePicker.Formatter.fullDateFormatter
    }


{-| Configuration for TimePicker
-}
type alias TimePickerConfig =
    { timeFormatter : Date -> String
    , timePickerType : TimePickerType
    }


type TimePickerType
    = Digital
    | Analog


{-| Default configuration for TimePicker
  * `onChange` No Default
  * `dateFormatter` Default: `"%m/%d/%Y"`
  * `dateTimeFormatter` Default: `"%m/%d/%Y %I:%M %p"`
  * `autoClose` Default: False
  * `timeFormatter` Default: `"%I:%M %p"`
  * `timePickerType` Default: Digital
-}
defaultTimePickerConfig : (State -> Maybe Date -> msg) -> Config TimePickerConfig msg
defaultTimePickerConfig onChange =
    { onChange = onChange
    , dateFormatter = DateTimePicker.Formatter.dateFormatter
    , dateTimeFormatter = DateTimePicker.Formatter.dateTimeFormatter
    , autoClose = False
    , timeFormatter = DateTimePicker.Formatter.timeFormatter
    , timePickerType = Digital
    }


{-| Default configuration for DateTimePicker

 * `onChange` No Default
 * `dateFormatter` Default: `"%m/%d/%Y"`
 * `dateTimeFormatter` Default: `"%m/%d/%Y %I:%M %p"`
 * `autoClose` Default: False
 * `nameOfDays` see `NameOfDays` for the default values.
 * `firstDayOfWeek` Default: Sunday.
 * `titleFormatter`  Default: `"%B %Y"`
 * `fullDateFormatter` Default:  `"%A, %B %d, %Y"`
 * `timeFormatter` Default: `"%I:%M %p"`
 * `timePickerType` Default:  Digital
-}
defaultDateTimePickerConfig : (State -> Maybe Date -> msg) -> Config (DatePickerConfig TimePickerConfig) msg
defaultDateTimePickerConfig onChange =
    { onChange = onChange
    , dateFormatter = DateTimePicker.Formatter.dateFormatter
    , dateTimeFormatter = DateTimePicker.Formatter.dateTimeFormatter
    , autoClose = False
    , nameOfDays = defaultNameOfDays
    , firstDayOfWeek = Date.Sun
    , titleFormatter = DateTimePicker.Formatter.titleFormatter
    , fullDateFormatter = DateTimePicker.Formatter.fullDateFormatter
    , timeFormatter = DateTimePicker.Formatter.timeFormatter
    , timePickerType = Digital
    }


{-| Configuration for name of days in a week.

This will be displayed as the calendar's header.
Default:
 * sunday = "Su"
 * monday = "Mo"
 * tuesday = "Tu"
 * wednesday = "We"
 * thursday = "Th"
 * friday = "Fr"
 * saturday = "Sa"
-}
type alias NameOfDays =
    { sunday : String
    , monday : String
    , tuesday : String
    , wednesday : String
    , thursday : String
    , friday : String
    , saturday : String
    }


defaultNameOfDays : NameOfDays
defaultNameOfDays =
    { sunday = "Su"
    , monday = "Mo"
    , tuesday = "Tu"
    , wednesday = "We"
    , thursday = "Th"
    , friday = "Fr"
    , saturday = "Sa"
    }


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
initialCmd : (State -> Maybe Date -> msg) -> State -> Cmd msg
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



-- ACTIONS


switchMode : Config a msg -> State -> (Maybe Date -> msg)
switchMode config state =
    let
        stateValue =
            getStateValue state
    in
        config.onChange <| InternalState { stateValue | event = "title" }


gotoNextMonth : Config a msg -> State -> (Maybe Date -> msg)
gotoNextMonth config state =
    let
        stateValue =
            getStateValue state

        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month 1) stateValue.titleDate
    in
        config.onChange <| InternalState { stateValue | event = "next", titleDate = updatedTitleDate }


gotoPreviousMonth : Config a msg -> State -> (Maybe Date -> msg)
gotoPreviousMonth config state =
    let
        stateValue =
            getStateValue state

        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month -1) stateValue.titleDate
    in
        config.onChange <| InternalState { stateValue | event = "previous", titleDate = updatedTitleDate }



-- VIEWS


type Type msg
    = DatePicker (Config (DatePickerConfig {}) msg)
    | DateTimePicker (Config (DatePickerConfig TimePickerConfig) msg)
    | TimePicker (Config TimePickerConfig msg)


{ id, class, classList } =
    datepickerNamespace


{-| Date Picker view function with default configuration.

Example:
    type alias Model = { datePickerState : DateTimePicker.State, value : Maybe Date }

    type  = DatePickerChanged DateTimePicker.State (Maybe Date)

    view =
        DateTimePicker.datePicker
                DatePickerChanged
                [ class "my-datepicker" ]
                model.datePickerState
                model.value

-}
datePicker : (State -> Maybe Date -> msg) -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
datePicker onChange =
    datePickerWithConfig (defaultDatePickerConfig onChange)


{-| Date Picker view function with custom configuration.

Example:
    type alias Model = { datePickerState : DateTimePicker.State, value : Maybe Date }

    type Msg = DatePickerChanged DateTimePicker.State (Maybe Date)

    customConfig =
        let default = (DateTimePicker.defaultConfig DatePickerChanged)
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
datePickerWithConfig : Config (DatePickerConfig {}) msg -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
datePickerWithConfig config =
    view (DatePicker config)


{-| Date and Time Picker view
Example:
    type alias Model = { dateTimePickerState : DateTimePicker.State, value : Maybe Date }

    type  = DatePickerChanged DateTimePicker.State (Maybe Date)

    view =
        DateTimePicker.dateTimePicker
                 DatePickerChanged
                [ class "my-datetimepicker" ]
                model.dateTimePickerState
                model.value
-}
dateTimePicker : (State -> Maybe Date -> msg) -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
dateTimePicker onChange =
    dateTimePickerWithConfig (defaultDateTimePickerConfig onChange)


{-| Date and Time Picker view
Example:
    type alias Model = { dateTimePickerState : DateTimePicker.State, value : Maybe Date }

    type  = DatePickerChanged DateTimePicker.State (Maybe Date)

    customConfig =
        let
            default = DateTimePicker.defaultDateTimePickerConfig DatePickerChanged
        in
            { default
                | firstDayOfWeek = Date.Mon
                , autoClose = True
            }

    view =
        DateTimePicker.dateTimePicker
                customConfig
                [ class "my-datetimepicker" ]
                model.dateTimePickerState
                model.value
-}
dateTimePickerWithConfig : Config (DatePickerConfig TimePickerConfig) msg -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
dateTimePickerWithConfig config =
    view (DateTimePicker config)


{-| Time Picker view
Example:
    type alias Model = { timePickerState : DateTimePicker.State, value : Maybe Date }

    type  = DatePickerChanged DateTimePicker.State (Maybe Date)

    DateTimePicker.timePicker
            (DateTimePicker.defaultConfig DatePickerChanged)
            DateTimePicker.defaultTimePickerConfig
            [ class "my-datetimepicker" ]
            model.timePickerState
            model.value
-}
timePickerWithConfig : Config TimePickerConfig msg -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
timePickerWithConfig config =
    view (TimePicker config)



-- timePicker : Config TimePickerConfig msg -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg


view : Type msg -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
view pickerType attributes state currentDate =
    let
        stateValue =
            getStateValue state

        timeFormatter dateTimePickerConfig =
            dateTimePickerConfig.timeFormatter

        formatter =
            case pickerType of
                DatePicker datePickerConfig ->
                    datePickerConfig.dateFormatter

                DateTimePicker dateTimePickerConfig ->
                    dateTimePickerConfig.dateTimeFormatter

                TimePicker dateTimePickerConfig ->
                    timeFormatter dateTimePickerConfig

        inputAttributes config =
            attributes
                ++ [ onFocus (datePickerFocused config stateValue currentDate)
                   , onBlurWithChange (inputChangeHandler config stateValue)
                   , value <| Maybe.withDefault "" <| Maybe.map formatter <| currentDate
                   ]

        shouldForceClose config =
            config.autoClose && stateValue.forceClose

        html config cssClasses =
            div
                [ cssClasses ]
                [ input (inputAttributes config) []
                , if stateValue.inputFocused && not (shouldForceClose config) then
                    dialog pickerType state currentDate
                  else
                    dialog pickerType state currentDate
                  -- text ""
                ]
    in
        case pickerType of
            DatePicker config ->
                html config (class [ DateTimePicker.SharedStyles.DatePicker ])

            DateTimePicker config ->
                html config (class [ DateTimePicker.SharedStyles.DatePicker, DateTimePicker.SharedStyles.TimePicker ])

            TimePicker config ->
                html config (class [ DateTimePicker.SharedStyles.TimePicker ])



-- VIEW HELPERSs


dialog : Type msg -> State -> Maybe Date -> Html msg
dialog pickerType state currentDate =
    let
        stateValue =
            getStateValue state

        attributes config =
            [ onMouseDownPreventDefault <| config.onChange (InternalState { stateValue | event = "dialog.onMouseDownPreventDefault" }) currentDate
            , onClick <| onChangeHandler pickerType stateValue currentDate
            , class [ Dialog ]
            ]
    in
        case pickerType of
            DatePicker datePickerConfig ->
                div (attributes datePickerConfig) [ datePickerDialog pickerType state currentDate ]

            TimePicker timePickerConfig ->
                div (attributes timePickerConfig) [ timePickerDialog pickerType state currentDate ]

            DateTimePicker timePickerConfig ->
                div (attributes timePickerConfig)
                    [ datePickerDialog pickerType state currentDate
                    , timePickerDialog pickerType state currentDate
                    ]


datePickerDialog : Type msg -> State -> Maybe Date -> Html msg
datePickerDialog pickerType state currentDate =
    let
        stateValue =
            getStateValue state

        title config =
            let
                date =
                    stateValue.titleDate
            in
                span
                    [ class [ Title ]
                    , onMouseDownPreventDefault <| switchMode config state currentDate
                    ]
                    [ date
                        |> Maybe.map config.titleFormatter
                        |> Maybe.withDefault "N/A"
                        |> text
                    ]

        previousButton config =
            span
                [ class [ ArrowLeft ]
                , onMouseDownPreventDefault <| gotoPreviousMonth config state currentDate
                ]
                [ DateTimePicker.Svg.leftArrow ]

        nextButton config =
            span
                [ class [ ArrowRight ]
                , onMouseDownPreventDefault <| gotoNextMonth config state currentDate
                ]
                [ DateTimePicker.Svg.rightArrow ]

        html config =
            div [ class [ DatePickerDialog ] ]
                [ div [ class [ Header ] ]
                    [ previousButton config
                    , title config
                    , nextButton config
                    ]
                , calendar pickerType state currentDate
                , div
                    [ class [ Footer ] ]
                    [ currentDate |> Maybe.map config.fullDateFormatter |> Maybe.withDefault "--" |> text ]
                ]
    in
        case pickerType of
            DatePicker config ->
                html config

            DateTimePicker config ->
                html config

            TimePicker _ ->
                text ""


timePickerDialog : Type msg -> State -> Maybe Date -> Html msg
timePickerDialog pickerType state currentDate =
    let
        html config =
            case config.timePickerType of
                Digital ->
                    digitalTimePickerDialog pickerType state currentDate

                Analog ->
                    analogTimePickerDialog pickerType state currentDate
    in
        case pickerType of
            DatePicker _ ->
                text ""

            DateTimePicker config ->
                html config

            TimePicker config ->
                html config


digitalTimePickerDialog : Type msg -> State -> Maybe Date -> Html msg
digitalTimePickerDialog pickerType state currentDate =
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
            List.map3 toRow (hours) (minutes) (ampmList ++ List.repeat 4 "")

        toRow hour min ampm =
            tr []
                [ hourCell hour
                , minuteCell min
                , amPmCell ampm
                ]

        hourCell hour =
            td
                [ onMouseDownPreventDefault <| hourClickHandler pickerType stateValue hour
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
                [ onMouseDownPreventDefault <| minuteClickHandler pickerType stateValue min
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
            td
                [ onMouseDownPreventDefault <| amPmClickHandler pickerType stateValue ampm
                , stateValue.time.amPm
                    |> Maybe.map ((==) ampm)
                    |> Maybe.map
                        (\selected ->
                            if selected then
                                class [ SelectedAmPm ]
                            else
                                class []
                        )
                    |> Maybe.withDefault (class [])
                ]
                [ text ampm ]

        upArrows config =
            [ tr [ class [ ArrowUp ] ]
                [ td [ onMouseDownPreventDefault <| hourUpHandler config stateValue currentDate ] [ DateTimePicker.Svg.upArrow ]
                , td [ onMouseDownPreventDefault <| minuteUpHandler config stateValue currentDate ] [ DateTimePicker.Svg.upArrow ]
                , td [] []
                ]
            ]

        downArrows config =
            [ tr [ class [ ArrowDown ] ]
                [ td [ onMouseDownPreventDefault <| hourDownHandler config stateValue currentDate ] [ DateTimePicker.Svg.downArrow ]
                , td [ onMouseDownPreventDefault <| minuteDownHandler config stateValue currentDate ] [ DateTimePicker.Svg.downArrow ]
                , td [] []
                ]
            ]

        html config =
            div [ class [ TimePickerDialog, DigitalTime ] ]
                [ div [ class [ Header ] ]
                    [ Maybe.map config.timeFormatter currentDate |> Maybe.withDefault "-- : --" |> text ]
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
    in
        case pickerType of
            DatePicker _ ->
                text ""

            DateTimePicker config ->
                html config

            TimePicker config ->
                html config


analogTimePickerDialog : Type msg -> State -> Maybe Date -> Html msg
analogTimePickerDialog pickerType state currentDate =
    let
        stateValue =
            getStateValue state

        isActive timeIndicator =
            if stateValue.activeTimeIndicator == Just timeIndicator then
                [ Active ]
            else
                []

        html config =
            div [ class [ TimePickerDialog, AnalogTime ] ]
                [ div [ class [ Header ] ]
                    [ span
                        [ onMouseDownPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.State.HourIndicator)
                        , class (Hour :: isActive DateTimePicker.State.HourIndicator)
                        ]
                        [ text (stateValue.time.hour |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
                    , span [ class [ Separator ] ] [ text " : " ]
                    , span
                        [ onMouseDownPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.State.MinuteIndicator)
                        , class (Minute :: isActive DateTimePicker.State.MinuteIndicator)
                        ]
                        [ text (stateValue.time.minute |> Maybe.map (toString >> DateTimePicker.DateUtils.padding) |> Maybe.withDefault "--") ]
                    , span
                        [ onMouseDownPreventDefault (timeIndicatorHandler config stateValue currentDate DateTimePicker.State.AMPMIndicator)
                        , class (AMPM :: isActive DateTimePicker.State.AMPMIndicator)
                        ]
                        [ text "--" ]
                    ]
                , div [ class [ Body ] ] [ DateTimePicker.AnalogClock.clock config.onChange state currentDate ]
                ]
    in
        case pickerType of
            DatePicker _ ->
                text ""

            DateTimePicker config ->
                html config

            TimePicker config ->
                html config


calendar : Type msg -> State -> Maybe Date -> Html msg
calendar pickerType state currentDate =
    let
        stateValue =
            getStateValue state

        html : Config (DatePickerConfig a) msg -> Html msg
        html config =
            case stateValue.titleDate of
                Nothing ->
                    Html.text ""

                Just titleDate ->
                    let
                        firstDay =
                            Date.Extra.Core.toFirstOfMonth titleDate
                                |> Date.dayOfWeek
                                |> DateTimePicker.DateUtils.dayToInt config.firstDayOfWeek

                        month =
                            Date.month titleDate

                        year =
                            Date.year titleDate

                        days =
                            DateTimePicker.DateUtils.generateCalendar config.firstDayOfWeek month year

                        header =
                            thead [ class [ DaysOfWeek ] ]
                                [ tr
                                    []
                                    (dayNames config)
                                ]

                        isHighlighted day =
                            stateValue.date
                                |> Maybe.map (\current -> day.day == Date.day current && month == Date.month current && year == Date.year current)
                                |> Maybe.withDefault False

                        isToday day =
                            stateValue.today
                                |> Maybe.map (\today -> day.day == Date.day today && month == Date.month today && year == Date.year today)
                                |> Maybe.withDefault False

                        toCell day =
                            td
                                [ class
                                    (case day.monthType of
                                        DateTimePicker.DateUtils.Previous ->
                                            [ PreviousMonth ]

                                        DateTimePicker.DateUtils.Current ->
                                            CurrentMonth
                                                :: if isHighlighted day then
                                                    [ SelectedDate ]
                                                   else if isToday day then
                                                    [ Today ]
                                                   else
                                                    []

                                        DateTimePicker.DateUtils.Next ->
                                            [ NextMonth ]
                                    )
                                , onMouseDownPreventDefault <| dateClickHandler pickerType stateValue year month day
                                ]
                                [ text <| toString day.day ]

                        toWeekRow week =
                            tr [] (List.map toCell week)

                        body =
                            tbody [ class [ Days ] ]
                                (days
                                    |> List.Extra.groupsOf 7
                                    |> List.map toWeekRow
                                )
                    in
                        table [ class [ Calendar ] ]
                            [ header
                            , body
                            ]
    in
        case pickerType of
            DatePicker config ->
                html config

            DateTimePicker config ->
                html config

            TimePicker config ->
                text ""


dayNames : Config (DatePickerConfig a) msg -> List (Html msg)
dayNames config =
    let
        days =
            [ th [] [ text config.nameOfDays.sunday ]
            , th [] [ text config.nameOfDays.monday ]
            , th [] [ text config.nameOfDays.tuesday ]
            , th [] [ text config.nameOfDays.wednesday ]
            , th [] [ text config.nameOfDays.thursday ]
            , th [] [ text config.nameOfDays.friday ]
            , th [] [ text config.nameOfDays.saturday ]
            ]

        shiftAmount =
            DateTimePicker.DateUtils.dayToInt Date.Sun config.firstDayOfWeek
    in
        days
            |> List.Extra.splitAt shiftAmount
            |> \( head, tail ) -> tail ++ head



-- EVENT HANDLERS


inputChangeHandler : Config a msg -> StateValue -> Maybe Date -> msg
inputChangeHandler config stateValue maybeDate =
    case Debug.log "currentDate" maybeDate of
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
                updatedValue =
                    { stateValue
                        | date = Nothing
                        , time = { hour = Nothing, minute = Nothing, amPm = Nothing }
                        , hourPickerStart = initialStateValue.hourPickerStart
                        , minutePickerStart = initialStateValue.minutePickerStart
                        , inputFocused = False
                        , event = "inputChangeHandler"
                    }
            in
                config.onChange (InternalState updatedValue) maybeDate


hourClickHandler : Type msg -> StateValue -> Int -> msg
hourClickHandler pickerType stateValue hour =
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
        case pickerType of
            DatePicker config ->
                withDateHandler config

            DateTimePicker config ->
                withDateHandler config

            TimePicker config ->
                justTimeHandler config


minuteClickHandler : Type msg -> StateValue -> Int -> msg
minuteClickHandler pickerType stateValue minute =
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
        case pickerType of
            DatePicker config ->
                withDateHandler config

            DateTimePicker config ->
                withDateHandler config

            TimePicker config ->
                justTimeHandler config


amPmClickHandler : Type msg -> StateValue -> String -> msg
amPmClickHandler pickerType stateValue amPm =
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
        case pickerType of
            DatePicker config ->
                withDateHandler config

            DateTimePicker config ->
                withDateHandler config

            TimePicker config ->
                justTimeHandler config


dateClickHandler : Type msg -> StateValue -> Int -> Date.Month -> DateTimePicker.DateUtils.Day -> msg
dateClickHandler pickerType stateValue year month day =
    let
        selectedDate =
            DateTimePicker.DateUtils.toDate year month day

        updatedStateValue =
            { stateValue | date = Just <| selectedDate, forceClose = forceClose }

        ( updatedDate, forceClose ) =
            case ( pickerType, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( DateTimePicker _, Just hour, Just minute, Just amPm ) ->
                    ( Just <| DateTimePicker.DateUtils.setTime selectedDate hour minute amPm
                    , True
                    )

                ( DatePicker _, _, _, _ ) ->
                    ( Just selectedDate
                    , True
                    )

                _ ->
                    ( Nothing, False )

        handler config =
            case day.monthType of
                DateTimePicker.DateUtils.Previous ->
                    gotoPreviousMonth config (InternalState updatedStateValue) updatedDate

                DateTimePicker.DateUtils.Next ->
                    gotoNextMonth config (InternalState updatedStateValue) updatedDate

                DateTimePicker.DateUtils.Current ->
                    config.onChange (InternalState updatedStateValue) updatedDate
    in
        case pickerType of
            DatePicker config ->
                handler config

            DateTimePicker config ->
                handler config

            TimePicker config ->
                handler config


datePickerFocused : Config a msg -> StateValue -> Maybe Date -> msg
datePickerFocused config stateValue currentDate =
    let
        updatedTitleDate =
            case currentDate of
                Nothing ->
                    stateValue.titleDate

                Just _ ->
                    currentDate
    in
        config.onChange
            (InternalState
                { stateValue
                    | inputFocused = True
                    , event = "onFocus"
                    , titleDate = updatedTitleDate
                    , forceClose = False
                }
            )
            currentDate


onChangeHandler : Type msg -> StateValue -> Maybe Date -> msg
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
            DatePicker config ->
                justDateHandler config

            DateTimePicker config ->
                withTimeHandler config

            TimePicker config ->
                withTimeHandler config


hourUpHandler : Config config msg -> StateValue -> Maybe Date -> msg
hourUpHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.hourPickerStart - 6 >= 1 then
                { stateValue | hourPickerStart = stateValue.hourPickerStart - 6 }
            else
                stateValue
    in
        config.onChange (InternalState updatedState) currentDate


hourDownHandler : Config config msg -> StateValue -> Maybe Date -> msg
hourDownHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.hourPickerStart + 6 <= 12 then
                { stateValue | hourPickerStart = stateValue.hourPickerStart + 6 }
            else
                stateValue
    in
        config.onChange (InternalState updatedState) currentDate


minuteUpHandler : Config config msg -> StateValue -> Maybe Date -> msg
minuteUpHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.minutePickerStart - 6 >= 0 then
                { stateValue | minutePickerStart = stateValue.minutePickerStart - 6 }
            else
                stateValue
    in
        config.onChange (InternalState updatedState) currentDate


minuteDownHandler : Config config msg -> StateValue -> Maybe Date -> msg
minuteDownHandler config stateValue currentDate =
    let
        updatedState =
            if stateValue.minutePickerStart + 6 <= 59 then
                { stateValue | minutePickerStart = stateValue.minutePickerStart + 6 }
            else
                stateValue
    in
        config.onChange (InternalState updatedState) currentDate


timeIndicatorHandler : Config config msg -> StateValue -> Maybe Date -> DateTimePicker.State.TimeIndicator -> msg
timeIndicatorHandler config stateValue currentDate timeIndicator =
    let
        updatedState =
            { stateValue | activeTimeIndicator = Just timeIndicator }
    in
        config.onChange (InternalState updatedState) currentDate
