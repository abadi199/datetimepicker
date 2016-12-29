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
        [ (.) DatePicker
            [ position relative, minWidth (px 475) ]
        , (.) Dialog
            [ fontFamilies [ "Arial", "Helvetica", "sans-serif" ]
            , fontSize (px 14)
            , borderBoxMixin
            , position absolute
            , border3 (px 1) solid (darkGray)
            , boxShadow4 (px 0) (px 5) (px 10) (rgba 0 0 0 0.2)
            , children dialogCss
            , property "z-index" "1"
            ]
        ]


dialogCss : List Css.Snippet
dialogCss =
    [ (.) DatePickerDialog
        [ float left
          -- , height calendarHeight
        , children datePickerDialogCss
        ]
    , (.) TimePickerDialog
        [ float left
          -- , height calendarHeight
        , textAlign center
        , borderLeft3 (px 1) solid (darkGray)
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
                [ fontSize (em 1.2)
                , padding2 (em 1) (em 0)
                , cursor pointer
                , margin2 (px 0) (auto)
                , width (px 85)
                , hover [ backgroundColor highlightedDay ]
                ]
    in
        [ width (px 230)
        , descendants
            [ (.) Header
                [ headerMixin
                , fontSize (em 1.2)
                , descendants
                    [ (.) Hour [ timeHeaderMixin ]
                    , (.) Minute [ timeHeaderMixin ]
                    , (.) AMPM [ timeHeaderMixin ]
                    , (.) Active
                        [ activeMixin ]
                    ]
                ]
            , (.) Body [ backgroundColor (hex "#fff"), padding2 (px 12) (px 15), height (px 202) ]
            , (.) AMPMPicker [ padding2 (px 40) (px 0) ]
            , (.) AM
                [ amPmMixin
                , withClass SelectedAmPm [ highlightMixin, hover [ highlightMixin ] ]
                ]
            , (.) PM
                [ amPmMixin
                , withClass SelectedAmPm [ highlightMixin, hover [ highlightMixin ] ]
                ]
            ]
        ]


digitalTimePickerDialogMixin : List Css.Mixin
digitalTimePickerDialogMixin =
    [ children
        [ (.) Header
            [ headerMixin
            ]
        , (.) Body
            [ backgroundColor (hex "#fff")
            , descendants
                [ table
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
                        , (.) SelectedHour [ highlightMixin, hover [ highlightMixin ] ]
                        , (.) SelectedMinute [ highlightMixin, hover [ highlightMixin ] ]
                        , (.) SelectedAmPm [ highlightMixin, hover [ highlightMixin ] ]
                        ]
                    ]
                ]
            ]
        ]
    ]


datePickerDialogCss : List Css.Snippet
datePickerDialogCss =
    [ (.) Header
        [ borderBoxMixin
        , headerMixin
        , position relative
        , children
            [ (.) ArrowLeft
                [ arrowMixin
                , left (px 0)
                ]
            , (.) ArrowRight
                [ arrowMixin
                , right (px 0)
                ]
            , (.) Title
                [ borderBoxMixin
                , display inlineBlock
                , width (pct 100)
                , textAlign center
                ]
            ]
        ]
    , (.) Calendar
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
                , backgroundColor (lightGray)
                , fontWeight normal
                , borderBottom3 (px 1) solid (darkGray)
                ]
            , (.) PreviousMonth
                [ color fadeText ]
            , (.) NextMonth
                [ color fadeText
                ]
            , (.) SelectedDate
                [ highlightMixin
                , hover [ highlightMixin ]
                ]
            , (.) Today
                [ property "box-shadow" "inset 0 0 7px 0 #76abd9"
                , highlightBorderMixin
                , hover
                    [ backgroundColor highlightSelectedDay ]
                ]
            ]
        ]
    , (.) Footer
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
        , backgroundColor (lightGray)
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
