module DateTimePicker.SharedStyles
    exposing
        ( CssClasses(..)
        , datepickerNamespace
        )

import Html.CssHelpers


datepickerNamespace : Html.CssHelpers.Namespace String class id msg
datepickerNamespace =
    Html.CssHelpers.withNamespace "elm-input-datepicker"


type CssClasses
    = Calendar
    | DaysOfWeek
    | PreviousMonth
    | CurrentMonth
    | Header
    | Body
    | NextMonth
    | Days
    | Title
    | ArrowLeft
    | ArrowRight
    | ArrowUp
    | ArrowDown
    | Dialog
    | DatePickerDialog
    | TimePickerDialog
    | DatePicker
    | TimePicker
    | Footer
    | SelectedDate
    | SelectedHour
    | SelectedMinute
    | SelectedAmPm
    | Today
    | DigitalTime
    | AnalogTime
    | AnalogClock
