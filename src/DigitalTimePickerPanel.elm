module DigitalTimePickerPanel exposing (Config, view)

import Date exposing (Date)
import DateTimePicker.DateUtils
import DateTimePicker.Events exposing (onBlurWithChange, onMouseDownPreventDefault, onMouseUpPreventDefault, onTouchEndPreventDefault, onTouchStartPreventDefault)
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


view : Config msg -> State -> Maybe Date.Date -> Html msg
view config ((InternalState stateValue) as state) currentDate =
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
