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
import DateTimePicker.SharedStyles exposing (CssClasses(..), datepickerNamespace)


{-| DatePicker's Css Stylesheet
-}
css : Css.Stylesheet
css =
    (Css.stylesheet << namespace datepickerNamespace.name)
        [ class DatePicker
            [ position relative ]
        , class Dialog
            [ fontFamilies [ "Arial", "Helvetica", "sans-serif" ]
            , fontSize (px 14)
            , borderBoxMixin
            , position absolute
            , border3 (px 1) solid darkGray
            , boxShadow4 (px 0) (px 5) (px 10) (rgba 0 0 0 0.2)
            , children dialogCss
            , property "z-index" "1"
            , displayFlex
            ]
        ]


dialogCss : List Css.Snippet
dialogCss =
    [ class DatePickerDialog
        [ float left

        -- , height calendarHeight
        , children datePickerDialogCss
        ]
    , class TimePickerDialog
        [ float left

        -- , height calendarHeight
        , textAlign center
        , borderLeft3 (px 1) solid darkGray
        , withClass DigitalTime digitalTimePickerDialogMixin
        , withClass AnalogTime analogTimePickerDialogMixin
        ]
    ]


analogTimePickerDialogMixin : List Css.Mixin
analogTimePickerDialogMixin =
    let
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
                , hover [ backgroundColor highlightedDay ]
                ]
    in
    [ width (px 230)
    , descendants
        [ class Header
            [ headerMixin
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


digitalTimePickerDialogMixin : List Css.Mixin
digitalTimePickerDialogMixin =
    [ children
        [ class Header
            [ headerMixin
            ]
        , class Body
            [ backgroundColor (hex "#fff")
            , descendants
                [ Css.Elements.table
                    [ tableMixin
                    , width (px 120)
                    , descendants
                        [ tr
                            [ verticalAlign top
                            , withClass ArrowUp
                                [ backgroundColor lightGray
                                , children
                                    [ td [ borderBottom3 (px 1) solid darkGray ]
                                    ]
                                ]
                            , withClass ArrowDown
                                [ backgroundColor lightGray
                                , children [ td [ borderTop3 (px 1) solid darkGray ] ]
                                ]
                            ]
                        , td
                            [ width (pct 33)
                            , cellMixin
                            , hover
                                [ backgroundColor highlightedDay
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


datePickerDialogCss : List Css.Snippet
datePickerDialogCss =
    [ class Header
        [ borderBoxMixin
        , headerMixin
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
        [ backgroundColor (hex "#ffffff")
        , tableMixin
        , width auto
        , margin (px 0)
        , descendants
            [ thead
                []
            , td
                [ dayMixin
                , hover
                    [ backgroundColor highlightedDay
                    , highlightBorderMixin
                    ]
                ]
            , th
                [ dayMixin
                , backgroundColor lightGray
                , fontWeight normal
                , borderBottom3 (px 1) solid darkGray
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
                    [ backgroundColor highlightSelectedDay ]
                ]
            ]
        ]
    , class Footer
        [ textAlign center
        , backgroundColor lightGray
        , padding2 (px 7) (px 7)
        , borderTop3 (px 1) solid darkGray
        , height (px 16)
        ]
    ]


highlightMixin : Css.Mixin
highlightMixin =
    mixin
        [ property "box-shadow" "inset 0 0 10px 3px #3276b1"
        , backgroundColor selectedDate
        , color (hex "#fff")
        , highlightBorderMixin
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


lightGray : Css.Color
lightGray =
    hex "#f5f5f5"


darkGray : Css.Color
darkGray =
    hex "#ccc"


highlightedDay : Css.Color
highlightedDay =
    hex "#ebebeb"


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


headerMixin : Css.Mixin
headerMixin =
    mixin
        [ padding2 (px 10) (px 7)
        , backgroundColor lightGray
        ]


calendarHeight : Css.Px
calendarHeight =
    px 277


tableMixin : Css.Mixin
tableMixin =
    mixin
        [ property "border-spacing" "0"
        , property "border-width" "0"
        , property "table-layout" "fixed"
        , margin (px 0)
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
