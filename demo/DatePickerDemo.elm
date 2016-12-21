module DatePickerDemo exposing (main)

import Html exposing (Html, text, p, label, form, ul, li, div)
import DatePicker exposing (defaultDatePickerOptions, defaultTimePickerOptions)
import Date exposing (Date)
import Css
import DatePicker.Css
import DemoCss exposing (CssClasses(..))
import Html.CssHelpers


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    { value : Maybe Date
    , datePickerState : DatePicker.State
    , secondValue : Maybe Date
    , secondDatePickerState : DatePicker.State
    }


init : ( Model, Cmd Msg )
init =
    ( { value = Nothing, datePickerState = DatePicker.initialState, secondValue = Nothing, secondDatePickerState = DatePicker.initialState }
    , Cmd.batch
        [ DatePicker.initialCmd DateChanged DatePicker.initialState
        , DatePicker.initialCmd SecondDateChanged DatePicker.initialState
        ]
    )


datePickerOptions : DatePicker.Options Msg
datePickerOptions =
    let
        defaultOptions =
            DatePicker.defaultOptions DateChanged
    in
        defaultOptions


secondDatePickerOptions : DatePicker.Options Msg
secondDatePickerOptions =
    let
        defaultOptions =
            DatePicker.defaultOptions SecondDateChanged
    in
        defaultOptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


{ id, class, classList } =
    Html.CssHelpers.withNamespace ""


view : Model -> Html Msg
view model =
    let
        { css } =
            Css.compile [ DatePicker.Css.css, DemoCss.css ]
    in
        form []
            [ Html.node "style" [] [ Html.text css ]
            , div [ class [ Container ] ]
                [ p
                    []
                    [ label []
                        [ text "Date Picker #1: "
                        , DatePicker.datePicker
                            datePickerOptions
                            defaultDatePickerOptions
                            []
                            model.datePickerState
                            model.value
                        ]
                    ]
                , p
                    []
                    [ label []
                        [ text "Date Picker #2 : "
                        , DatePicker.dateTimePicker
                            secondDatePickerOptions
                            defaultDatePickerOptions
                            defaultTimePickerOptions
                            []
                            model.secondDatePickerState
                            model.secondValue
                        ]
                    ]
                , p []
                    [ ul []
                        [ li []
                            -- [ text "Value: ", text <| toString model.value ]
                            -- , li []
                            [ text "Second Value: ", text <| toString model.secondValue ]
                        ]
                    ]
                ]
            ]


type Msg
    = NoOp
    | DateChanged DatePicker.State (Maybe Date)
    | SecondDateChanged DatePicker.State (Maybe Date)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DateChanged state value ->
            ( { model | value = value, datePickerState = state }, Cmd.none )

        SecondDateChanged state value ->
            ( { model | secondValue = value, secondDatePickerState = state }, Cmd.none )
