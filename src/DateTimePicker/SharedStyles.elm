module DateTimePicker.SharedStyles
    exposing
        ( CssClasses(..)
        , htmlNamespace
        , svgNamespace
        )

import Html.CssHelpers
import Svg.CssHelpers


htmlNamespace : Html.CssHelpers.Namespace String class id msg
htmlNamespace =
    Html.CssHelpers.withNamespace namespace


svgNamespace : Html.CssHelpers.Namespace String class id msg
svgNamespace =
    Svg.CssHelpers.withNamespace namespace


namespace : String
namespace =
    "elm-input-datepicker"


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
    | Arrow
    | DoubleArrow
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
