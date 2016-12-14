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
        )

{-| DatePicker

# View
@docs datePicker, dateTimePicker, Options, DatePickerOptions, TimePickerOptions, defaultDatePickerOptions, NameOfDays, defaultOptions, defaultTimePickerOptions

# Initial
@docs initialState, initialStateWithToday, initialCmd

# Internal State
@docs State
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
    }


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


onMouseDown : msg -> Html.Attribute msg
onMouseDown msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
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

        datePickerAttributes =
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
            [ input datePickerAttributes []
              -- , if stateValue.inputFocused || stateValue.dialogFocused then
            , if True then
                dialog options pickerType state currentDate
              else
                text ""
            ]



-- VIEW HELPERSs


dialog : Options msg -> Type -> State -> Maybe Date -> Html msg
dialog options pickerType state currentDate =
    let
        stateValue =
            getStateValue state

        attributes options =
            [ onMouseDown <| options.toMsg <| State { stateValue | dialogFocused = True, event = "onMouseDown" }
            , onMouseUp <| options.toMsg <| State { stateValue | dialogFocused = False, inputFocused = True, event = "onMouseUp" }
            , class [ Dialog ]
            ]
    in
        case pickerType of
            DatePicker datePickerOptions ->
                div (attributes options) [ datePickerDialog options datePickerOptions state currentDate ]

            TimePicker timePickerOptions ->
                div (attributes options) [ timePickerDialog options timePickerOptions state currentDate ]

            DateTimePicker datePickerOptions timePickerOptions ->
                div (attributes options)
                    [ datePickerDialog options datePickerOptions state currentDate
                    , timePickerDialog options timePickerOptions state currentDate
                    ]


datePickerDialog : Options msg -> DatePickerOptions -> State -> Maybe Date -> Html msg
datePickerDialog options datePickerOptions state currentDate =
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
            , calendar options datePickerOptions state currentDate
            , div
                [ class [ Footer ] ]
                [ currentDate |> Maybe.map datePickerOptions.fullDateFormatter |> Maybe.withDefault "--" |> text ]
            ]


timePickerDialog : Options msg -> TimePickerOptions -> State -> Maybe Date -> Html msg
timePickerDialog options timePickerOptions state currentDate =
    let
        toListItem str =
            li [] [ text str ]

        hours =
            List.range 1 12 |> List.map (toString >> DatePicker.DateUtils.padding)

        minutes =
            List.range 0 59 |> List.map (toString >> DatePicker.DateUtils.padding)

        ampm =
            [ "AM", "PM" ]

        timeSelector =
            List.map3 toRow (List.take 6 hours) (List.take 6 minutes) (ampm ++ List.repeat 4 "")

        toRow hour min ampm =
            tr [] [ td [] [ text hour ], td [] [ text min ], td [] [ text ampm ] ]

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


calendar : Options msg -> DatePickerOptions -> State -> Maybe Date -> Html msg
calendar options datePickerOptions state currentDate =
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
                            , onClick <| options.onChange <| Just <| DatePicker.DateUtils.toDate year month day
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
