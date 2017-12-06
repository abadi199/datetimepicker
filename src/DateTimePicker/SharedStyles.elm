module DateTimePicker.SharedStyles
    exposing
        ( CssClasses(..)
        )

{-| Shared CSS Classes used by `DateTimePicker`. You can use this to overwrite the default CSS implementation to match your own styling.

@docs CssClasses

-}


{-| All CSS Classes
-}
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
    | NoYearNavigation
    | ArrowLeft
    | ArrowRight
    | DoubleArrowLeft
    | DoubleArrowRight
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
    | Active
    | Hour
    | Minute
    | AMPM
    | Separator
    | AMPMPicker
    | AM
    | PM
    | EmptyCell
