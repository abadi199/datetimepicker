module DatePicker.Formatter
    exposing
        ( titleFormatter
        , dateFormatter
        , dateTimeFormatter
        , fullDateFormatter
        , timeFormatter
        )

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format


titleFormatter : Date -> String
titleFormatter =
    Date.Extra.Format.format config "%B %Y"


dateFormatter : Date -> String
dateFormatter =
    Date.Extra.Format.format config "%m/%d/%Y"


fullDateFormatter : Date -> String
fullDateFormatter =
    Date.Extra.Format.format config "%A, %B %d, %Y"


dateTimeFormatter : Date -> String
dateTimeFormatter =
    Date.Extra.Format.format config "%m/%d/%Y %I:%M %p"


timeFormatter : Date -> String
timeFormatter =
    Date.Extra.Format.format config "%I:%M %p"
