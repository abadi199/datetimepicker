module DateTimePicker.Config
    exposing
        ( Config
        , DatePickerConfig
        , TimePickerConfig
        , TimePickerType(..)
        , NameOfDays
        , Type(..)
        , InputFormat
        , I18n
        , defaultDatePickerConfig
        , defaultTimePickerConfig
        , defaultDateTimePickerConfig
        , defaultI18n
        , defaultDateInputFormat
        , defaultDateTimeInputFormat
        )

{-| DateTimePicker configuration

# Configuration
@docs Config, I18n, InputFormat, DatePickerConfig, TimePickerConfig, NameOfDays, TimePickerType, Type


# Default Configuration
@docs defaultDatePickerConfig, defaultTimePickerConfig, defaultDateTimePickerConfig, defaultI18n, defaultDateInputFormat, defaultDateTimeInputFormat
-}

import Date exposing (Date)
import DateTimePicker.Internal exposing (InternalState)
import DateTimePicker.Formatter
import DateParser
import Date.Extra.Config.Config_en_us exposing (config)


type alias State =
    InternalState


{-| The type of picker (for Internal Use)
-}
type Type msg
    = DateType (Config (DatePickerConfig {}) msg)
    | DateTimeType (Config (DatePickerConfig TimePickerConfig) msg)
    | TimeType (Config TimePickerConfig msg)


{-| Configuration

 * `onChange` is the message for when the selected value and internal `State` in the date picker has changed.
 * `autoClose` is a flag to indicate whether the dialog should be automatically closed when a date and/or time is selected.
 * `allowYearNavigation` show/hide year navigation button.
 * `i18n` is internationalization configuration.
-}
type alias Config otherConfig msg =
    { otherConfig
        | onChange : State -> Maybe Date -> msg
        , autoClose : Bool
        , allowYearNavigation : Bool
        , i18n : I18n
    }


{-| Internationalization configuration

 * `footerFormatter` is a Date to string formatter used to display the date in the footer section.
 * `titleFormatter` is a Date to string formatter used to display the date in the title section.
 * `timeTitleFormatter` is a Date to string formatter used to display the time in the title section.
 * `inputFormat` is an input date formatter and parser.
-}
type alias I18n =
    { titleFormatter : Date -> String
    , footerFormatter : Date -> String
    , timeTitleFormatter : Date -> String
    , inputFormat : InputFormat
    }


{-| Configuration for the DatePicker

 * `nameOfDays` is the configuration for name of days in a week.
 * `firstDayOfWeek` is the first day of the week.
 * `titleFormatter` is the Date to String formatter for the dialog's title.
 * `footerFormatter` is the Date to String formatter for the dialog's footer.
 * `allowYearNavigation` show/hide year navigation button.
-}
type alias DatePickerConfig otherConfig =
    { otherConfig
        | nameOfDays : NameOfDays
        , firstDayOfWeek : Date.Day
    }


{-| Input formatter and parser

* `inputFormatter` is a Date to string formatter used to display the date in the input text
* `inputParser` is a String to Date parser used to parsed input text into Date
-}
type alias InputFormat =
    { inputFormatter : Date -> String
    , inputParser : String -> Maybe Date
    }


{-| Default configuration for DatePicker

 * `onChange` No Default
 * `autoClose` Default: True
 * `nameOfDays` see `NameOfDays` for the default values.
 * `firstDayOfWeek` Default: Sunday.
 * `allowYearNavigation` Default : True
-}
defaultDatePickerConfig : (State -> Maybe Date -> msg) -> Config (DatePickerConfig {}) msg
defaultDatePickerConfig onChange =
    { onChange = onChange
    , autoClose = True
    , nameOfDays = defaultNameOfDays
    , firstDayOfWeek = Date.Sun
    , allowYearNavigation = True
    , i18n = defaultI18n
    }


{-| Default internationalization

 * `titleFormatter`  Default: `"%B %Y"`
 * `footerFormatter` Default:  `"%A, %B %d, %Y"`
 * `inputFormat` Default: browser default format and pattern
-}
defaultI18n : I18n
defaultI18n =
    { titleFormatter = DateTimePicker.Formatter.titleFormatter
    , footerFormatter = DateTimePicker.Formatter.footerFormatter
    , timeTitleFormatter = DateTimePicker.Formatter.timeFormatter
    , inputFormat = defaultDateInputFormat
    }


{-| Default input format for date picker
-}
defaultDateInputFormat : InputFormat
defaultDateInputFormat =
    { inputFormatter = DateTimePicker.Formatter.dateFormatter
    , inputParser = DateParser.parse config DateTimePicker.Formatter.datePattern >> Result.toMaybe
    }


{-| Default input format for date and time picker
-}
defaultDateTimeInputFormat : InputFormat
defaultDateTimeInputFormat =
    { inputFormatter = DateTimePicker.Formatter.dateTimeFormatter
    , inputParser = DateParser.parse config DateTimePicker.Formatter.dateTimePattern >> Result.toMaybe
    }


{-| Default input format for time picker
-}
defaultTimeInputFormat : InputFormat
defaultTimeInputFormat =
    { inputFormatter = DateTimePicker.Formatter.timeFormatter
    , inputParser = DateParser.parse config DateTimePicker.Formatter.timePattern >> Result.toMaybe
    }


{-| Configuration for TimePicker

 * `timePickerType` is the type of the time picker, either Analog or Digital
-}
type alias TimePickerConfig =
    { timePickerType : TimePickerType
    }


{-| The type of time picker, can be either Digital or Analog
-}
type TimePickerType
    = Digital
    | Analog


{-| Default configuration for TimePicker
  * `onChange` No Default
  * `dateFormatter` Default: `"%m/%d/%Y"`
  * `dateTimeFormatter` Default: `"%m/%d/%Y %I:%M %p"`
  * `autoClose` Default: False
  * `timeFormatter` Default: `"%I:%M %p"`
  * `timePickerType` Default: Analog
  * `allowYearNavigation` Default : True
-}
defaultTimePickerConfig : (State -> Maybe Date -> msg) -> Config TimePickerConfig msg
defaultTimePickerConfig onChange =
    { onChange = onChange
    , autoClose = False
    , timePickerType = Analog
    , allowYearNavigation = True
    , i18n = defaultI18n
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
 * `timePickerType` Default:  Analog
 * `allowYearNavigation` Default : True
-}
defaultDateTimePickerConfig : (State -> Maybe Date -> msg) -> Config (DatePickerConfig TimePickerConfig) msg
defaultDateTimePickerConfig onChange =
    { onChange = onChange
    , autoClose = False
    , nameOfDays = defaultNameOfDays
    , firstDayOfWeek = Date.Sun
    , timePickerType = Analog
    , allowYearNavigation = True
    , i18n = defaultI18n
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
