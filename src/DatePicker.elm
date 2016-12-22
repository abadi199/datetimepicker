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
    { onChange : State -> Maybe Date -> msg
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
defaultOptions : (State -> Maybe Date -> msg) -> Options msg
defaultOptions onChange =
    { onChange = onChange, dateFormatter = DatePicker.Formatter.dateFormatter, dateTimeFormatter = DatePicker.Formatter.dateTimeFormatter }


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
    , forceClose : Bool
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
        , forceClose = False
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
        , forceClose = False
        , event = ""
        , today = Just today
        , titleDate = Just <| Date.Extra.Core.toFirstOfMonth today
        , date = Nothing
        , time = Time Nothing Nothing Nothing
        }


{-| Initial Cmd to set the initial month to be displayed in the datepicker to the current month.
-}
initialCmd : (State -> Maybe Date -> msg) -> State -> Cmd msg
initialCmd onChange state =
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
            ((setDate >> onChange |> flip) Nothing)
            Date.now


{-| Get the internal state values
-}
getStateValue : State -> StateValue
getStateValue state =
    case state of
        State stateValue ->
            stateValue



-- EVENTS


onBlurWithChange : (Maybe Date -> msg) -> Html.Attribute msg
onBlurWithChange tagger =
    Html.Events.on "blur"
        (Json.Decode.map (Date.fromString >> Result.toMaybe >> tagger) Html.Events.targetValue)


onMouseDownPreventDefault : msg -> Html.Attribute msg
onMouseDownPreventDefault msg =
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


onMouseUpPreventDefault : msg -> Html.Attribute msg
onMouseUpPreventDefault msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "mouseup" eventOptions (Json.Decode.succeed msg)


onMouseUp : msg -> Html.Attribute msg
onMouseUp msg =
    let
        eventOptions =
            { preventDefault = False
            , stopPropagation = False
            }
    in
        Html.Events.onWithOptions "mouseup" eventOptions (Json.Decode.succeed msg)



-- ACTIONS


switchMode : Options msg -> State -> (Maybe Date -> msg)
switchMode options state =
    let
        stateValue =
            getStateValue state
    in
        options.onChange <| State { stateValue | event = "title" }


gotoNextMonth : Options msg -> State -> (Maybe Date -> msg)
gotoNextMonth options state =
    let
        stateValue =
            getStateValue state

        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month 1) stateValue.titleDate
    in
        options.onChange <| State { stateValue | event = "next", titleDate = updatedTitleDate }


gotoPreviousMonth : Options msg -> State -> (Maybe Date -> msg)
gotoPreviousMonth options state =
    let
        stateValue =
            getStateValue state

        updatedTitleDate =
            Maybe.map (Date.Extra.Duration.add Date.Extra.Duration.Month -1) stateValue.titleDate
    in
        options.onChange <| State { stateValue | event = "previous", titleDate = updatedTitleDate }



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

        inputAttributes =
            attributes
                ++ [ onFocus (datePickerFocused options stateValue currentDate)
                   , onBlurWithChange (inputChangeHandler options stateValue)
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
            , if stateValue.inputFocused && not stateValue.forceClose then
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
            [ onMouseDownPreventDefault <| options.onChange (State { stateValue | event = "dialog.onMouseDownPreventDefault" }) currentDate
            , onClick <| onChangeHandler options pickerType stateValue currentDate
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
                    , onMouseDownPreventDefault <| switchMode options state currentDate
                    ]
                    [ date
                        |> Maybe.map datePickerOptions.titleFormatter
                        |> Maybe.withDefault "N/A"
                        |> text
                    ]

        previousButton =
            span
                [ class [ ArrowLeft ]
                , onMouseDownPreventDefault <| gotoPreviousMonth options state currentDate
                ]
                [ DatePicker.Svg.leftArrow ]

        nextButton =
            span
                [ class [ ArrowRight ]
                , onMouseDownPreventDefault <| gotoNextMonth options state currentDate
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
                [ onMouseDownPreventDefault <| hourClickHandler options pickerType stateValue hour
                  -- , onMouseDown <| hourMouseDownHandler options pickerType stateValue hour
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
                [ onMouseDownPreventDefault <| minuteClickHandler options pickerType stateValue min
                  -- , onMouseDown <| minuteMouseDownHandler options pickerType stateValue min
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
                [ onMouseDownPreventDefault <| amPmClickHandler options pickerType stateValue ampm
                  -- , onMouseDown <| amPmMouseDownHandler options pickerType stateValue ampm
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
                            , onMouseDownPreventDefault <| dateClickHandler options pickerType stateValue year month day
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


inputChangeHandler : Options msg -> StateValue -> Maybe Date -> msg
inputChangeHandler options stateValue maybeDate =
    case maybeDate of
        Just date ->
            let
                updateTime time =
                    { time
                        | hour = Date.hour date |> DatePicker.DateUtils.fromMillitaryHour |> Just
                        , minute = Just (Date.minute date)
                        , amPm = Date.hour date |> DatePicker.DateUtils.fromMillitaryAmPm |> Just
                    }

                updatedValue =
                    { stateValue
                        | date = Just date
                        , time = updateTime stateValue.time
                        , inputFocused = False
                        , event = "inputChangeHandler"
                    }
            in
                options.onChange (State updatedValue) maybeDate

        Nothing ->
            let
                updatedValue =
                    { stateValue | date = Nothing, inputFocused = False, event = "inputChangeHandler" }
            in
                options.onChange (State updatedValue) maybeDate


hourClickHandler : Options msg -> Type -> StateValue -> Int -> msg
hourClickHandler options pickerType stateValue hour =
    let
        time =
            stateValue.time

        updatedStateValue =
            { stateValue | time = { time | hour = Just hour }, event = "hourClickHandler" }

        ( updatedDate, forceCloseWithDate ) =
            case ( stateValue.time.minute, stateValue.time.amPm, stateValue.date ) of
                ( Just minute, Just amPm, Just date ) ->
                    ( Just <| DatePicker.DateUtils.setTime date hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        ( updatedTime, forceCloseTimeOnly ) =
            case ( updatedStateValue.time.minute, updatedStateValue.time.amPm ) of
                ( Just minute, Just amPm ) ->
                    ( Just <| DatePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        withDateHandler =
            options.onChange (State { updatedStateValue | forceClose = forceCloseWithDate }) updatedDate

        justTimeHandler =
            options.onChange (State { updatedStateValue | forceClose = forceCloseTimeOnly }) updatedTime
    in
        case pickerType of
            DatePicker _ ->
                withDateHandler

            DateTimePicker _ _ ->
                withDateHandler

            TimePicker _ ->
                justTimeHandler


minuteClickHandler : Options msg -> Type -> StateValue -> Int -> msg
minuteClickHandler options pickerType stateValue minute =
    let
        time =
            stateValue.time

        updatedStateValue =
            { stateValue | time = { time | minute = Just minute }, event = "minuteClickHandler" }

        ( updatedDate, forceCloseWithDate ) =
            case ( stateValue.time.hour, stateValue.time.amPm, stateValue.date ) of
                ( Just hour, Just amPm, Just date ) ->
                    ( Just <| DatePicker.DateUtils.setTime date hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        ( updatedTime, forceCloseTimeOnly ) =
            case ( updatedStateValue.time.hour, updatedStateValue.time.amPm ) of
                ( Just hour, Just amPm ) ->
                    ( Just <| DatePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        withDateHandler =
            options.onChange (State { updatedStateValue | forceClose = forceCloseWithDate }) updatedDate

        justTimeHandler =
            options.onChange (State { updatedStateValue | forceClose = forceCloseTimeOnly }) updatedTime
    in
        case pickerType of
            DatePicker _ ->
                withDateHandler

            DateTimePicker _ _ ->
                withDateHandler

            TimePicker _ ->
                justTimeHandler


amPmClickHandler : Options msg -> Type -> StateValue -> String -> msg
amPmClickHandler options pickerType stateValue amPm =
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
                    ( Just <| DatePicker.DateUtils.setTime date hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        ( updatedTime, forceCloseTimeOnly ) =
            case ( updatedStateValue.time.hour, updatedStateValue.time.minute ) of
                ( Just hour, Just minute ) ->
                    ( Just <| DatePicker.DateUtils.toTime hour minute amPm
                    , True
                    )

                _ ->
                    ( Nothing, False )

        withDateHandler =
            options.onChange (State { updatedStateValue | forceClose = forceCloseWithDate }) updatedDate

        justTimeHandler =
            options.onChange (State { updatedStateValue | forceClose = forceCloseTimeOnly }) updatedTime
    in
        case pickerType of
            DatePicker _ ->
                withDateHandler

            DateTimePicker _ _ ->
                withDateHandler

            TimePicker _ ->
                justTimeHandler


dateClickHandler : Options msg -> Type -> StateValue -> Int -> Date.Month -> DatePicker.DateUtils.Day -> msg
dateClickHandler options pickerType stateValue year month day =
    let
        selectedDate =
            DatePicker.DateUtils.toDate year month day

        updatedStateValue =
            { stateValue | date = Just <| selectedDate, forceClose = forceClose }

        ( updatedDate, forceClose ) =
            case ( pickerType, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( DateTimePicker _ _, Just hour, Just minute, Just amPm ) ->
                    ( Just <| DatePicker.DateUtils.setTime selectedDate hour minute amPm
                    , True
                    )

                ( DatePicker _, _, _, _ ) ->
                    ( Just selectedDate
                    , True
                    )

                _ ->
                    ( Nothing, False )
    in
        case day.monthType of
            DatePicker.DateUtils.Previous ->
                gotoPreviousMonth options (State updatedStateValue) updatedDate

            DatePicker.DateUtils.Next ->
                gotoNextMonth options (State updatedStateValue) updatedDate

            DatePicker.DateUtils.Current ->
                options.onChange (State updatedStateValue) updatedDate


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
        options.onChange
            (State
                { stateValue
                    | inputFocused = True
                    , event = "onFocus"
                    , titleDate = updatedTitleDate
                    , forceClose = False
                }
            )
            currentDate


onChangeHandler : Options msg -> Type -> StateValue -> Maybe Date -> msg
onChangeHandler options pickerType stateValue currentDate =
    let
        justDateHandler =
            options.onChange (State stateValue) stateValue.date

        withTimeHandler =
            case ( stateValue.date, stateValue.time.hour, stateValue.time.minute, stateValue.time.amPm ) of
                ( Just date, Just hour, Just minute, Just amPm ) ->
                    options.onChange (State stateValue) <| Just <| DatePicker.DateUtils.setTime date hour minute amPm

                _ ->
                    options.onChange (State stateValue) Nothing
    in
        case pickerType of
            DatePicker _ ->
                justDateHandler

            DateTimePicker _ _ ->
                withTimeHandler

            TimePicker _ ->
                withTimeHandler
