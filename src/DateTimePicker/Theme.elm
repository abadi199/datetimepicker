module DateTimePicker.Theme
    exposing
        ( Theme(..)
        , ThemeConfiguration
        , backgroundColor
        , configuration
        , foregroundColor
        , highlight
        )

import Css
import Theme.Dark as Dark
import Theme.Light as Light


type Theme
    = Dark
    | Light
    | Custom ThemeConfiguration


type alias ThemeConfiguration =
    { highlight : List Css.Mixin
    , backgroundColor : Css.Color
    , foregroundColor : Css.Color
    }


configuration : Theme -> ThemeConfiguration
configuration theme =
    case theme of
        Dark ->
            Dark.themeConfiguration

        Light ->
            Light.themeConfiguration

        Custom themeConfiguration ->
            themeConfiguration


highlight : Theme -> Css.Mixin
highlight theme =
    configuration theme
        |> .highlight
        |> Css.mixin


backgroundColor : Theme -> Css.Color
backgroundColor theme =
    configuration theme
        |> .backgroundColor


foregroundColor : Theme -> Css.Color
foregroundColor theme =
    configuration theme
        |> .foregroundColor
