module DateTimePicker.Formatter
    exposing
        ( titleFormatter
        , dateFormatter
        , dateTimeFormatter
        , footerFormatter
        , timeFormatter
        , titlePattern
        , datePattern
        , dateTimePattern
        , footerPattern
        , timePattern
        )

import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format


titleFormatter : Date -> String
titleFormatter =
    Date.Extra.Format.format config titlePattern


titlePattern : String
titlePattern =
    "%B %Y"


dateFormatter : Date -> String
dateFormatter =
    Date.Extra.Format.format config datePattern


datePattern : String
datePattern =
    "%m/%d/%Y"


footerFormatter : Date -> String
footerFormatter =
    Date.Extra.Format.format config footerPattern


footerPattern : String
footerPattern =
    "%A, %B %d, %Y"


dateTimeFormatter : Date -> String
dateTimeFormatter =
    Date.Extra.Format.format config dateTimePattern


dateTimePattern : String
dateTimePattern =
    "%m/%d/%Y %I:%M %p"


timeFormatter : Date -> String
timeFormatter =
    Date.Extra.Format.format config timePattern


timePattern : String
timePattern =
    "%I:%M %p"
