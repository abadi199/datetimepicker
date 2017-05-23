module DateTimePicker.Css exposing (css)

{-| DateTimePicker.Css

Using [rtfeldman/elm-css](http://package.elm-lang.org/packages/rtfeldman/elm-css/latest)
Include this in your elm-css port module to be included in your project's css file.


# Css

@docs css

-}

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)
import DateTimePicker.SharedStyles exposing (CssClasses(..), htmlNamespace)
import DateTimePicker.Theme as Theme exposing (Theme)


{-| DatePicker's Css Stylesheet
-}
css : Theme -> Css.Stylesheet
css theme =
    let
        foregroundColor =
            Theme.foregroundColor .headerFooter theme

        borderColor =
            Theme.borderColor .headerFooter theme
    in
    (Css.stylesheet << namespace htmlNamespace.name)
        [ class DatePicker
            [ position relative, minWidth (px 475) ]
        , class Dialog
            [ fontFamilies [ "Arial", "Helvetica", "sans-serif" ]
            , fontSize (px 14)
            , borderBoxMixin
            , position absolute
            , border3 (px 1) solid borderColor
            , boxShadow4 (px 0) (px 5) (px 10) (rgba 0 0 0 0.2)
            , children (dialogCss theme)
            , property "z-index" "1"
            ]
        , class Arrow
            [ fill foregroundColor
            ]
        ]


dialogCss : Theme -> List Css.Snippet
dialogCss theme =
    let
        borderColor =
            Theme.borderColor .headerFooter theme
    in
    [ class DatePickerDialog
        [ float left
        , children (datePickerDialogCss theme)
        ]
    , class TimePickerDialog
        [ float left
        , textAlign center
        , borderLeft3 (px 1) solid borderColor
        , withClass DigitalTime (digitalTimePickerDialogMixin theme)
        , withClass AnalogTime (analogTimePickerDialogMixin theme)
        ]
    ]


analogTimePickerDialogMixin : Theme -> List Css.Mixin
analogTimePickerDialogMixin theme =
    let
        hoverColor =
            Theme.hoverColor .body theme

        timeHeaderMixin =
            mixin
                [ padding2 (px 3) (px 10)
                , marginTop (px 3)
                , marginBottom (px 3)
                , display inlineBlock
                , cursor pointer
                ]

        amPmMixin =
            mixin
                [ fontSize (Css.em 1.2)
                , padding2 (Css.em 1) (Css.em 0)
                , cursor pointer
                , margin2 (px 0) auto
                , width (px 85)
                , hover [ backgroundColor hoverColor ]
                ]

        highlightMixin =
            Theme.highlight theme
    in
    [ width (px 230)
    , descendants
        [ class Header
            [ headerMixin theme
            , fontSize (Css.em 1.2)
            , descendants
                [ class Hour [ timeHeaderMixin ]
                , class Minute [ timeHeaderMixin ]
                , class AMPM [ timeHeaderMixin ]
                , class Active
                    [ activeMixin ]
                ]
            ]
        , class Body [ backgroundColor (hex "#fff"), padding2 (px 12) (px 15), height (px 202) ]
        , class AMPMPicker [ padding2 (px 40) (px 0) ]
        , class AM
            [ amPmMixin
            , withClass SelectedAmPm [ highlightMixin, hover [ highlightMixin ] ]
            ]
        , class PM
            [ amPmMixin
            , withClass SelectedAmPm [ highlightMixin, hover [ highlightMixin ] ]
            ]
        ]
    ]


digitalTimePickerDialogMixin : Theme -> List Css.Mixin
digitalTimePickerDialogMixin theme =
    let
        highlightMixin =
            Theme.highlight theme

        backgroundColor =
            Theme.backgroundColor .headerFooter theme

        borderColor =
            Theme.borderColor .headerFooter theme

        bodyHoverColor =
            Theme.hoverColor .body theme
    in
    [ children
        [ class Header
            [ headerMixin theme
            ]
        , class Body
            [ Css.backgroundColor (hex "#fff")
            , descendants
                [ Css.Elements.table
                    [ tableMixin theme
                    , width (px 120)
                    , descendants
                        [ tr
                            [ verticalAlign top
                            , withClass ArrowUp
                                [ Css.backgroundColor backgroundColor
                                , children
                                    [ td
                                        [ borderBottom3 (px 1) solid borderColor
                                        , hover
                                            [ Css.backgroundColor backgroundColor
                                            ]
                                        ]
                                    ]
                                ]
                            , withClass ArrowDown
                                [ Css.backgroundColor backgroundColor
                                , children
                                    [ td
                                        [ borderTop3 (px 1) solid borderColor
                                        , hover
                                            [ Css.backgroundColor backgroundColor
                                            , highlightBorderMixin
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        , td
                            [ width (pct 33)
                            , cellMixin
                            , hover
                                [ Css.backgroundColor bodyHoverColor
                                , highlightBorderMixin
                                ]
                            , withClass EmptyCell [ emptyCellMixin ]
                            ]
                        , class SelectedHour [ highlightMixin, hover [ highlightMixin ] ]
                        , class SelectedMinute [ highlightMixin, hover [ highlightMixin ] ]
                        , class SelectedAmPm [ highlightMixin, hover [ highlightMixin ] ]
                        ]
                    ]
                ]
            ]
        ]
    ]


datePickerDialogCss : Theme -> List Css.Snippet
datePickerDialogCss theme =
    let
        highlightMixin =
            Theme.highlight theme

        backgroundColor =
            Theme.backgroundColor .headerFooter theme

        foregroundColor =
            Theme.foregroundColor .headerFooter theme

        borderColor =
            Theme.borderColor .headerFooter theme

        hoverColor =
            Theme.hoverColor .body theme
    in
    [ class Header
        [ borderBoxMixin
        , headerMixin theme
        , position relative
        , children
            [ class ArrowLeft
                [ arrowMixin
                , left (px 22)
                , withClass NoYearNavigation [ left (px 0) ]
                ]
            , class DoubleArrowLeft
                [ arrowMixin
                , left (px 0)
                ]
            , class ArrowRight
                [ arrowMixin
                , right (px 22)
                , withClass NoYearNavigation [ right (px 0) ]
                ]
            , class DoubleArrowRight
                [ arrowMixin
                , right (px 0)
                ]
            , class Title
                [ borderBoxMixin
                , display inlineBlock
                , width (pct 100)
                , textAlign center
                ]
            ]
        ]
    , class Calendar
        [ tableMixin theme
        , width auto
        , margin (px 0)
        , descendants
            [ thead
                []
            , td
                [ dayMixin
                , hover
                    [ Css.backgroundColor hoverColor
                    , highlightBorderMixin
                    ]
                ]
            , th
                [ dayMixin
                , Css.backgroundColor backgroundColor
                , color foregroundColor
                , fontWeight normal
                , borderBottom3 (px 1) solid borderColor
                ]
            , class PreviousMonth
                [ color fadeText ]
            , class NextMonth
                [ color fadeText
                ]
            , class SelectedDate
                [ highlightMixin
                , hover [ highlightMixin ]
                ]
            , class Today
                [ property "box-shadow" "inset 0 0 7px 0 #76abd9"
                , highlightBorderMixin
                , hover
                    [ Css.backgroundColor highlightSelectedDay ]
                ]
            ]
        ]
    , class Footer
        [ textAlign center
        , Css.backgroundColor backgroundColor
        , padding2 (px 7) (px 7)
        , borderTop3 (px 1) solid borderColor
        , height (px 16)
        , color foregroundColor
        ]
    ]


highlightSelectedDay : Css.Color
highlightSelectedDay =
    hex "#d5e5f3"


selectedDate : Css.Color
selectedDate =
    hex "#428bca"


fadeText : Css.Color
fadeText =
    hex "#a1a1a1"


dayMixin : Css.Mixin
dayMixin =
    mixin
        [ cellMixin
        , textAlign right
        ]


cellMixin : Css.Mixin
cellMixin =
    mixin
        [ padding4 (px 7) (px 7) (px 7) (px 9)
        , border (px 0)
        , cursor pointer
        ]


arrowMixin : Css.Mixin
arrowMixin =
    mixin
        [ borderBoxMixin
        , textAlign center
        , transform (scale 0.8)
        , position absolute
        , padding2 (px 0) (px 8)
        , cursor pointer
        ]


borderBoxMixin : Css.Mixin
borderBoxMixin =
    mixin [ boxSizing borderBox ]


highlightBorderMixin : Css.Mixin
highlightBorderMixin =
    mixin [ borderRadius (px 0) ]


headerMixin : Theme -> Css.Mixin
headerMixin theme =
    mixin
        [ padding2 (px 10) (px 7)
        , backgroundColor (Theme.backgroundColor .headerFooter theme)
        , color (Theme.foregroundColor .headerFooter theme)
        ]


calendarHeight : Css.Px
calendarHeight =
    px 277


tableMixin : Theme -> Css.Mixin
tableMixin theme =
    let
        bodyBackgroundColor =
            Theme.backgroundColor .body theme
    in
    mixin
        [ property "border-spacing" "0"
        , property "border-width" "0"
        , property "table-layout" "fixed"
        , margin (px 0)
        , backgroundColor bodyBackgroundColor
        ]


activeMixin : Css.Mixin
activeMixin =
    mixin
        [ backgroundColor (hex "#e0e0e0")
        , highlightBorderMixin
        ]


emptyCellMixin : Css.Mixin
emptyCellMixin =
    mixin [ hover [ backgroundColor unset ], cursor unset ]
