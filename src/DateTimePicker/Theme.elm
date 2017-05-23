module DateTimePicker.Theme
    exposing
        ( Theme(..)
        , ThemeConfiguration
        , backgroundColor
        , borderColor
        , configuration
        , foregroundColor
        , highlight
        , hoverColor
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
    , headerFooter : Palette
    , body : Palette
    }


type alias Palette =
    { background : Css.Color
    , foreground : Css.Color
    , hover : Css.Color
    , border : Css.Color
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


backgroundColor : (ThemeConfiguration -> Palette) -> Theme -> Css.Color
backgroundColor section theme =
    configuration theme
        |> section
        |> .background


foregroundColor : (ThemeConfiguration -> Palette) -> Theme -> Css.Color
foregroundColor section theme =
    configuration theme
        |> section
        |> .foreground


borderColor : (ThemeConfiguration -> Palette) -> Theme -> Css.Color
borderColor section theme =
    configuration theme
        |> section
        |> .border


hoverColor : (ThemeConfiguration -> Palette) -> Theme -> Css.Color
hoverColor section theme =
    configuration theme
        |> section
        |> .hover
