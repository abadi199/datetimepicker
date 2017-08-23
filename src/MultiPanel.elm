module MultiPanel exposing (view)

import AnalogTimePickerPanel
import Date
import DatePickerPanel
import DateTimePicker.Config exposing (TimePickerType(..))
import DateTimePicker.DateUtils
import DateTimePicker.Internal exposing (InternalState(..))
import Html exposing (Html)
import TimePickerPanel exposing (digital)


type alias State =
    InternalState


view : DatePickerPanel.Config msg -> ( TimePickerType, TimePickerPanel.Config msg ) -> State -> Maybe Date.Date -> List (Html msg)
view dateConfig ( timeType, timeConfig ) state currentDate =
    let
        safeOnChange (InternalState state) _ =
            -- we ignore the provided value
            -- (which may come from either the date or the time panel)
            -- and instead check the state
            -- to see if both a date and time have been picked
            dateConfig.onChange (InternalState state)
                (case ( state.date, state.time.hour, state.time.minute, state.time.amPm ) of
                    ( Just date, Just hour, Just minute, Just amPm ) ->
                        Just <| DateTimePicker.DateUtils.setTime date hour minute amPm

                    _ ->
                        Nothing
                )

        safeDateConfig =
            { dateConfig | onChange = safeOnChange }

        safeTimeConfig =
            { timeConfig | onChange = safeOnChange }
    in
    [ DatePickerPanel.view safeDateConfig state currentDate
    , case timeType of
        Digital ->
            TimePickerPanel.digital safeTimeConfig state currentDate

        Analog ->
            AnalogTimePickerPanel.view safeTimeConfig state currentDate
    ]
