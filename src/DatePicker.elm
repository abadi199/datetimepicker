module DatePicker
    exposing
        ( Options
        , DatePickerOptions
        , TimePickerOptions
        , NameOfDays
        , datePicker
        , dateTimePicker
        , defaultOptions
        , defaultDatePickerOptions
        , defaultTimePickerOptions
        , State
        , initialState
        , initialStateWithToday
        , initialCmd
        , getStateValue
        )

{-| DatePicker

# View
@docs datePicker, dateTimePicker, Options, DatePickerOptions, TimePickerOptions, defaultDatePickerOptions, NameOfDays, defaultOptions, defaultTimePickerOptions

# Initial
@docs initialState, initialStateWithToday, initialCmd

# Internal State
@docs State, getStateValue
-}

import Date exposing (Date)
import Html exposing (Html, input, div, span, text, button, table, tr, td, th, thead, tbody, ul, li)
import Html.Attributes exposing (value)
import Html.Events exposing (onFocus, onBlur, onClick)
import Json.Decode
import Task
import DatePicker.Formatter
import DatePicker.Svg
import DatePicker.DateUtils
import Date.Extra.Core
import Date.Extra.Duration
import List.Extra
import DatePicker.SharedStyles exposing (datepickerNamespace, CssClasses(..))
import String


-- MODEL


{-| Configuration
 * `onChange` is the message for when the selected value in the multi-select is changed. (Required)
 * `toMsg` is the Msg for updating internal `State` of the DatePicker element. (Required)
-}
type alias Options msg =
    { onChange : Maybe Date -> msg
    , toMsg : State -> msg
    , dateFormatter : Date -> String
    , dateTimeFormatter : Date -> String
    }


{-| Configuration for the DatePicker
 * `nameOfDays` is the configuration for name of days in a week. (Optional)
 * `firstDayOfWeek` is the first day of the week. (Optional)
 * `formatter` is the Date to String formatter for the input value. (Optional)
 * `titleFormatter` is the Date to String formatter for the dialog's title. (Optional)
 * `fullDateFormatter` is the Date to String formatter for the dialog's footer. (Optional)

-}
type alias DatePickerOptions =
    { nameOfDays : NameOfDays
    , firstDayOfWeek : Date.Day
    , titleFormatter : Date -> String
    , fullDateFormatter : Date -> String
    }


{-| Configuration for the TimePicker
-}
type alias TimePickerOptions =
    { timeFormatter : Date -> String
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


{-| Default configuration
 * `dateFormatter` Default: `"%m/%d/%Y"`
-}
defaultOptions : (Maybe Date -> msg) -> (State -> msg) -> Options msg
defaultOptions onChange toMsg =
    { onChange = onChange, toMsg = toMsg, dateFormatter = DatePicker.Formatter.dateFormatter, dateTimeFormatter = DatePicker.Formatter.dateTimeFormatter }


{-| Default configuration for DatePicker

 * `nameOfDays` see `NameOfDays` for the default values.
 * `firstDayOfWeek` Default: Sunday. (Optional)
 * `dateFormatter` Default: `"%m/%d/%Y"` (Optional)
 * `titleFormatter`  Default: `"%B %Y"` (Optional)
 * `fullDateFormatter` Default:  `"%A, %B %d, %Y"` (Optional)

-}
defaultDatePickerOptions : DatePickerOptions
defaultDatePickerOptions =
    { nameOfDays = defaultNameOfDays
    , firstDayOfWeek = Date.Sun
    , titleFormatter = DatePicker.Formatter.titleFormatter
    , fullDateFormatter = DatePicker.Formatter.fullDateFormatter
    }


{-| Default configuration for TimePicker
-}
defaultTimePickerOptions : TimePickerOptions
defaultTimePickerOptions =
    { timeFormatter = DatePicker.Formatter.timeFormatter
    }


{-| Opaque type to keep track of the DatePicker internal state
-}
type State
    = State StateValue


type alias StateValue =
    { inputFocused : Bool
    , dialogFocused : Bool
    , event : String
    , today : Maybe Date
    , titleDate : Maybe Date
    , date : Maybe Date
    , time : Time
    }


type alias Time =
    { hour : Maybe Int, minute : Maybe Int, amPm : Maybe String }


{-| Initial state of the DatePicker
-}
initialState : State
initialState =
    State
        { inputFocused = False
        , dialogFocused = False
        , event = ""
        , today = Nothing
        , titleDate = Nothing
        , date = Nothing
        , time = Time Nothing Nothing Nothing
        }


{-| Initial state of the DatePicker with today Date
-}
initialStateWithToday : Date.Date -> State
initialStateWithToday today =
    State
        { inputFocused = False
        , dialogFocused = False
        , event = ""
        , today = Just today
        , titleDate = Just <| Date.Extra.Core.toFirstOfMonth today
        , date = Nothing
        , time = Time Nothing Nothing Nothing
        }


{-| Initial Cmd to set the initial month to be displayed in the datepicker to the current month.
-}
initialCmd : (State -> msg) -> State -> Cmd msg
initialCmd toMsg state =
    let
        stateValue =
            getStateValue state

        setDate now =
            State
                { stateValue
                    | today = Just now
                    , titleDate = Just <| Date.Extra.Core.toFirstOfMonth now
                }
    in
        Task.perform
            (setDate >> toMsg)
            Date.now


{-| Get the internal state values
-}
getStateValue : State -> StateValue
getStateValue state =
    case state of
        State stateValue ->
            stateValue



-- EVENTS


onChange : (Maybe Date -> msg) -> Html.Attribute msg
onChange tagger =
    Html.Events.on "change"
        (Json.Decode.map (Date.fromString >> Result.toMaybe >> tagger) Html.Events.targetValue)


onMouseDownStop : msg -> Html.Attribute msg
onMouseDownStop msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "mousedown" eventOptions (Json.Decode.succeed msg)


onMouseDown : msg -> Html.Attribute msg
onMouseDown msg =
    let
        eventOptions =
            { preventDefault = False
            , stopPropagation = False
            }
    in
        Html.Events.onWithOptions "mousedown" eventOptions (Json.Decode.succeed msg)


onMouseUp : msg -> Html.Attribute msg
onMouseUp msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "mouseup" eventOptions (Json.Decode.succeed msg)



-- ACTIONS


switchMode : Options msg -> State -> msg
switchMode options state =
    let
        stateValue =
            getStateValue state
    in
        options.toMsg <| State { stateValue | dialogFocused = False, event = "title" }


gotoNextMonth : Options msg -> State -> msg
gotoNextMonth options state =
    let
        stateValue =
            getStateValue state

        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month 1) stateValue.titleDate
    in
        options.toMsg <| State { stateValue | dialogFocused = False, event = "next", titleDate = updatedTitleDate }


gotoPreviousMonth : Options msg -> State -> msg
gotoPreviousMonth options state =
    let
        stateValue =
            getStateValue state

        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month -1) stateValue.titleDate
    in
        options.toMsg <| State { stateValue | dialogFocused = False, event = "previous", titleDate = updatedTitleDate }



-- VIEWS


type Type
    = DatePicker DatePickerOptions
    | DateTimePicker DatePickerOptions TimePickerOptions
    | TimePicker TimePickerOptions


{ id, class, classList } =
    datepickerNamespace


{-| Date Picker view function.

Example:

    DatePicker.datePicker
            datePickerOptions
            [ class "my-datepicker" ]
            model.datePickerState
            model.value

-}
datePicker : Options msg -> DatePickerOptions -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
datePicker options datePickerOptions =
    view options (DatePicker datePickerOptions)


{-| Date and Time Picker view
-}
dateTimePicker : Options msg -> DatePickerOptions -> TimePickerOptions -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
dateTimePicker options datePickerOptions timePickerOptions =
    view options (DateTimePicker datePickerOptions timePickerOptions)


view : Options msg -> Type -> List (Html.Attribute msg) -> State -> Maybe Date -> Html msg
view options pickerType attributes state currentDate =
    let
        _ =
            Debug.log "view" stateValue.time

        stateValue =
            getStateValue state

        formatter =
            case pickerType of
                DatePicker _ ->
                    options.dateFormatter

                TimePicker timePickerOptions ->
                    timePickerOptions.timeFormatter

                DateTimePicker _ _ ->
                    options.dateTimeFormatter

        inputAttributes =
            attributes
                ++ [ onFocus (datePickerFocused options stateValue currentDate)
                   , onBlur <|
                        options.toMsg <|
                            State
                                { stateValue
                                    | inputFocused = False
                                    , event = "onBlur"
                                }
                   , onChange options.onChange
                   , value <| Maybe.withDefault "" <| Maybe.map formatter <| currentDate
                   ]
    in
        div
            [ case pickerType of
                DatePicker _ ->
                    class [ DatePicker.SharedStyles.DatePicker ]

                DateTimePicker _ _ ->
                    class [ DatePicker.SharedStyles.DatePicker, DatePicker.SharedStyles.TimePicker ]

                TimePicker _ ->
                    class [ DatePicker.SharedStyles.TimePicker ]
            ]
            [ input inputAttributes []
            , if stateValue.inputFocused || stateValue.dialogFocused then
                dialog options pickerType state currentDate
              else
                text ""
            ]



-- VIEW HELPERSs


dialog : Options msg -> Type -> State -> Maybe Date -> Html msg
dialog options pickerType state currentDate =
    let
        _ =
            Debug.log "dialog" stateValue.time

        stateValue =
            getStateValue state

        attributes options =
            [ onMouseDownStop <| options.toMsg <| State { stateValue | dialogFocused = True, event = "onMouseDown" }
            , onMouseUp <| options.toMsg <| State { stateValue | dialogFocused = False, inputFocused = True, event = "onMouseUp" }
            , class [ Dialog ]
            ]
    in
        case pickerType of
            DatePicker datePickerOptions ->
                div (attributes options) [ datePickerDialog options pickerType datePickerOptions state currentDate ]

            TimePicker timePickerOptions ->
                div (attributes options) [ timePickerDialog options pickerType timePickerOptions state currentDate ]

            DateTimePicker datePickerOptions timePickerOptions ->
                div (attributes options)
                    [ datePickerDialog options pickerType datePickerOptions state currentDate
                    , timePickerDialog options pickerType timePickerOptions state currentDate
                    ]


datePickerDialog : Options msg -> Type -> DatePickerOptions -> State -> Maybe Date -> Html msg
datePickerDialog options pickerType datePickerOptions state currentDate =
    let
        stateValue =
            getStateValue state

        title =
            let
                date =
                    stateValue.titleDate
            in
                span
                    [ class [ Title ]
                    , onMouseUp <| switchMode options state
                    ]
                    [ date
                        |> Maybe.map datePickerOptions.titleFormatter
                        |> Maybe.withDefault "N/A"
                        |> text
                    ]

        previousButton =
            span
                [ class [ ArrowLeft ]
                , onMouseUp <| gotoPreviousMonth options state
                ]
                [ DatePicker.Svg.leftArrow ]

        nextButton =
            span
                [ class [ ArrowRight ]
                , onMouseUp <| gotoNextMonth options state
                ]
                [ DatePicker.Svg.rightArrow ]
    in
        div [ class [ DatePickerDialog ] ]
            [ div [ class [ Header ] ]
                [ previousButton
                , title
                , nextButton
                ]
            , calendar options pickerType datePickerOptions state currentDate
            , div
                [ class [ Footer ] ]
                [ currentDate |> Maybe.map datePickerOptions.fullDateFormatter |> Maybe.withDefault "--" |> text ]
            ]


timePickerDialog : Options msg -> Type -> TimePickerOptions -> State -> Maybe Date -> Html msg
timePickerDialog options pickerType timePickerOptions state currentDate =
    let
        stateValue =
            getStateValue state

        toListItem str =
            li [] [ text str ]

        hours =
            List.range 1 12

        minutes =
            List.range 0 59

        ampm =
            [ "AM", "PM" ]

        timeSelector =
            List.map3 toRow (List.take 6 hours) (List.take 6 minutes) (ampm ++ List.repeat 4 "")

        toRow hour min ampm =
            tr []
                [ hourCell hour
                , minuteCell min
                , amPmCell ampm
                ]

        hourCell hour =
            td
                [ onClick <| hourClickHandler options pickerType stateValue hour
                , onMouseDown <| hourMouseDownHandler options pickerType stateValue hour
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
                [ text <| (toString >> DatePicker.DateUtils.padding) hour ]

        minuteCell min =
            td
                [ onClick <| minuteClickHandler options pickerType stateValue min
                , onMouseDown <| minuteMouseDownHandler options pickerType stateValue min
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
                [ text <| (toString >> DatePicker.DateUtils.padding) min ]

        amPmCell ampm =
            td
                [ onClick <| amPmClickHandler options pickerType stateValue ampm
                , onMouseDown <| amPmMouseDownHandler options pickerType stateValue ampm
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

        upArrows =
            [ tr [ class [ ArrowUp ] ] [ td [] [ DatePicker.Svg.upArrow ], td [] [ DatePicker.Svg.upArrow ], td [] [] ] ]

        downArrows =
            [ tr [ class [ ArrowDown ] ] [ td [] [ DatePicker.Svg.downArrow ], td [] [ DatePicker.Svg.downArrow ], td [] [] ] ]
    in
        div [ class [ TimePickerDialog ] ]
            [ div [ class [ Header ] ]
                [ Maybe.map timePickerOptions.timeFormatter currentDate |> Maybe.withDefault "-- : --" |> text ]
            , div [ class [ Body ] ]
                [ table []
                    [ tbody []
                        (upArrows
                            ++ timeSelector
                            ++ downArrows
                        )
                    ]
                ]
            ]


calendar : Options msg -> Type -> DatePickerOptions -> State -> Maybe Date -> Html msg
calendar options pickerType datePickerOptions state currentDate =
    let
        stateValue =
            getStateValue state
    in
        case stateValue.titleDate of
            Nothing ->
                Html.text ""

            Just titleDate ->
                let
                    firstDay =
                        Date.Extra.Core.toFirstOfMonth titleDate
                            |> Date.dayOfWeek
                            |> DatePicker.DateUtils.dayToInt datePickerOptions.firstDayOfWeek

                    month =
                        Date.month titleDate

                    year =
                        Date.year titleDate

                    days =
                        DatePicker.DateUtils.generateCalendar datePickerOptions.firstDayOfWeek month year

                    header =
                        thead [ class [ DaysOfWeek ] ]
                            [ tr
                                []
                                (dayNames datePickerOptions)
                            ]

                    isHighlighted day =
                        currentDate
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
                                    DatePicker.DateUtils.Previous ->
                                        [ PreviousMonth ]

                                    DatePicker.DateUtils.Current ->
                                        CurrentMonth
                                            :: if isHighlighted day then
                                                [ SelectedDate ]
                                               else if isToday day then
                                                [ Today ]
                                               else
                                                []

                                    DatePicker.DateUtils.Next ->
                                        [ NextMonth ]
                                )
                            , onClick <| dateClickHandler options pickerType stateValue year month day
                            , onMouseDown <| dateMouseDownHandler options pickerType stateValue year month day
                            , State
                                { stateValue
                                    | dialogFocused = False
                                    , inputFocused = False
                                    , event = "onChange"
                                }
                                |> (\updatedState ->
                                        case day.monthType of
                                            DatePicker.DateUtils.Previous ->
                                                gotoPreviousMonth options updatedState

                                            DatePicker.DateUtils.Next ->
                                                gotoNextMonth options updatedState

                                            DatePicker.DateUtils.Current ->
                                                options.toMsg updatedState
                                   )
                                |> onMouseUp
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


dayNames : DatePickerOptions -> List (Html msg)
dayNames options =
    let
        days =
            [ th [] [ text options.nameOfDays.sunday ]
            , th [] [ text options.nameOfDays.monday ]
            , th [] [ text options.nameOfDays.tuesday ]
            , th [] [ text options.nameOfDays.wednesday ]
            , th [] [ text options.nameOfDays.thursday ]
            , th [] [ text options.nameOfDays.friday ]
            , th [] [ text options.nameOfDays.saturday ]
            ]

        shiftAmount =
            DatePicker.DateUtils.dayToInt Date.Sun options.firstDayOfWeek
    in
        days
            |> List.Extra.splitAt shiftAmount
            |> \( head, tail ) -> tail ++ head



-- EVENT HANDLERS


hourClickHandler : Options msg -> Type -> StateValue -> Int -> msg
hourClickHandler options pickerType stateValue hour =
    let
        time =
            stateValue.time

        withDateHandler =
            case ( stateValue.date, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( Just date, _, Just minute, Just amPm ) ->
                    DatePicker.DateUtils.toDateTime (Date.year date) (Date.month date) (DatePicker.DateUtils.Day DatePicker.DateUtils.Current <| Date.day date) hour minute
                        |> Just
                        |> options.onChange

                _ ->
                    options.toMsg <| State { stateValue | time = { time | hour = Just hour } }

        justTimeHandler =
            case ( stateValue.time.minute, stateValue.time.amPm ) of
                ( Just minute, Just amPm ) ->
                    DatePicker.DateUtils.toDateTime 1900 Date.Jan (DatePicker.DateUtils.Day DatePicker.DateUtils.Current 1) hour minute
                        |> Just
                        |> options.onChange

                _ ->
                    options.toMsg <| State { stateValue | time = { time | hour = Just hour } }
    in
        case pickerType of
            DatePicker _ ->
                withDateHandler

            DateTimePicker _ _ ->
                withDateHandler

            TimePicker _ ->
                justTimeHandler


hourMouseDownHandler : Options msg -> Type -> StateValue -> Int -> msg
hourMouseDownHandler options pickerType stateValue hour =
    let
        _ =
            Debug.log "hourMouseDownHandler" stateValue.time

        time =
            stateValue.time
    in
        options.toMsg <|
            State
                { stateValue
                    | time = { time | hour = Just hour }
                    , event = "hour mouseDown"
                }


minuteClickHandler : Options msg -> Type -> StateValue -> Int -> msg
minuteClickHandler options pickerType stateValue minute =
    let
        time =
            stateValue.time

        withDateHandler =
            case ( stateValue.date, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( Just date, Just hour, _, Just amPm ) ->
                    DatePicker.DateUtils.toDateTime (Date.year date) (Date.month date) (DatePicker.DateUtils.Day DatePicker.DateUtils.Current <| Date.day date) hour minute
                        |> Just
                        |> options.onChange

                _ ->
                    options.toMsg <| State { stateValue | time = { time | minute = Just minute } }

        justTimeHandler =
            case ( stateValue.time.hour, stateValue.time.amPm ) of
                ( Just hour, Just amPm ) ->
                    DatePicker.DateUtils.toDateTime 1900 Date.Jan (DatePicker.DateUtils.Day DatePicker.DateUtils.Current 1) hour minute
                        |> Just
                        |> options.onChange

                _ ->
                    options.toMsg <| State { stateValue | time = { time | minute = Just minute } }
    in
        case pickerType of
            DatePicker _ ->
                withDateHandler

            DateTimePicker _ _ ->
                withDateHandler

            TimePicker _ ->
                justTimeHandler


minuteMouseDownHandler : Options msg -> Type -> StateValue -> Int -> msg
minuteMouseDownHandler options pickerType stateValue minute =
    let
        _ =
            Debug.log "minuteMouseDownHandler" stateValue.time

        time =
            stateValue.time
    in
        options.toMsg <|
            State
                { stateValue
                    | time = { time | minute = Just minute }
                    , event = "minute mouseDown"
                }


amPmClickHandler : Options msg -> Type -> StateValue -> String -> msg
amPmClickHandler options pickerType stateValue amPm =
    let
        time =
            stateValue.time

        withDateHandler =
            case ( stateValue.date, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( Just date, Just hour, Just minute, _ ) ->
                    DatePicker.DateUtils.toDateTime (Date.year date) (Date.month date) (DatePicker.DateUtils.Day DatePicker.DateUtils.Current <| Date.day date) hour minute
                        |> Just
                        |> options.onChange

                _ ->
                    options.toMsg <|
                        (State
                            { stateValue
                                | time =
                                    { time
                                        | amPm =
                                            if String.isEmpty amPm then
                                                Nothing
                                            else
                                                Just amPm
                                    }
                                , event = "amPm mouseDown"
                            }
                        )

        justTimeHandler =
            case ( stateValue.time.hour, stateValue.time.minute ) of
                ( Just hour, Just minute ) ->
                    DatePicker.DateUtils.toDateTime 1900 Date.Jan (DatePicker.DateUtils.Day DatePicker.DateUtils.Current 1) hour minute
                        |> Just
                        |> options.onChange

                _ ->
                    options.toMsg <|
                        (State
                            { stateValue
                                | time =
                                    { time
                                        | amPm =
                                            if String.isEmpty amPm then
                                                Nothing
                                            else
                                                Just amPm
                                    }
                                , event = "amPm mouseDown"
                            }
                        )
    in
        case pickerType of
            DatePicker _ ->
                withDateHandler

            DateTimePicker _ _ ->
                withDateHandler

            TimePicker _ ->
                justTimeHandler


amPmMouseDownHandler : Options msg -> Type -> StateValue -> String -> msg
amPmMouseDownHandler options pickerType stateValue amPm =
    let
        _ =
            Debug.log "amPmMouseDownHandler" stateValue.time

        time =
            stateValue.time
    in
        options.toMsg <|
            (State
                { stateValue
                    | time =
                        { time
                            | amPm =
                                if String.isEmpty amPm then
                                    Nothing
                                else
                                    Just amPm
                        }
                    , event = "amPm mouseDown"
                }
            )


dateClickHandler : Options msg -> Type -> StateValue -> Int -> Date.Month -> DatePicker.DateUtils.Day -> msg
dateClickHandler options pickerType stateValue year month day =
    let
        withTimeHandler =
            case ( stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( Just hour, Just minute, Just amPm ) ->
                    DatePicker.DateUtils.toDateTime year month day hour minute
                        |> Just
                        |> options.onChange

                _ ->
                    options.toMsg <| State { stateValue | date = Just <| DatePicker.DateUtils.toDate year month day }

        justDateHandler =
            DatePicker.DateUtils.toDate year month day
                |> Just
                |> options.onChange
    in
        case pickerType of
            DatePicker _ ->
                justDateHandler

            DateTimePicker _ _ ->
                withTimeHandler

            TimePicker _ ->
                withTimeHandler


dateMouseDownHandler : Options msg -> Type -> StateValue -> Int -> Date.Month -> DatePicker.DateUtils.Day -> msg
dateMouseDownHandler options pickerType stateValue year month day =
    DatePicker.DateUtils.toDate year month day
        |> (\date ->
                State
                    { stateValue
                        | date = Just date
                        , event = "date mouseDown"
                        , dialogFocused = True
                    }
           )
        |> options.toMsg


datePickerFocused : Options msg -> StateValue -> Maybe Date -> msg
datePickerFocused options stateValue currentDate =
    let
        updatedTitleDate =
            case currentDate of
                Nothing ->
                    stateValue.titleDate

                Just _ ->
                    currentDate
    in
        State
            { stateValue
                | inputFocused = True
                , event = "onFocus"
                , titleDate = updatedTitleDate
            }
            |> options.toMsg
