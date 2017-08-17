module MultiPanel exposing (view)

import Date
import DatePickerPanel
import DateTimePicker.Config exposing (TimePickerType(..))
import DateTimePicker.Internal exposing (InternalState(..))
import Html exposing (Html)
import TimePickerPanel exposing (analog, digital)


type alias State =
    InternalState


view : DatePickerPanel.Config msg -> ( TimePickerType, TimePickerPanel.Config msg ) -> State -> Maybe Date.Date -> List (Html msg)
view dateConfig ( timeType, timeConfig ) state currentDate =
    [ DatePickerPanel.view dateConfig state currentDate
    , case timeType of
        Digital ->
            TimePickerPanel.digital timeConfig state currentDate

        Analog ->
            TimePickerPanel.analog timeConfig state currentDate
    ]
