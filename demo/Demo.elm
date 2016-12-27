module Demo exposing (main)

import Html exposing (Html, text, p, label, form, ul, li, div)
import DateTimePicker
import DateTimePicker.Config exposing (defaultDatePickerConfig, defaultDateTimePickerConfig)
import Date exposing (Date)
import Css
import DateTimePicker.Css
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
    { dateValue : Maybe Date
    , datePickerState : DateTimePicker.State
    , dateTimeValue : Maybe Date
    , dateTimePickerState : DateTimePicker.State
    , analogDateTimeValue : Maybe Date
    , analogDateTimePickerState : DateTimePicker.State
    }


init : ( Model, Cmd Msg )
init =
    ( { dateValue = Nothing
      , datePickerState = DateTimePicker.initialState
      , dateTimeValue = Nothing
      , dateTimePickerState = DateTimePicker.initialState
      , analogDateTimeValue = Nothing
      , analogDateTimePickerState = DateTimePicker.initialState
      }
    , Cmd.batch
        [ DateTimePicker.initialCmd DateChanged DateTimePicker.initialState
        , DateTimePicker.initialCmd DateTimeChanged DateTimePicker.initialState
        , DateTimePicker.initialCmd AnalogDateTimeChanged DateTimePicker.initialState
        ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


{ id, class, classList } =
    Html.CssHelpers.withNamespace ""


view : Model -> Html Msg
view model =
    let
        { css } =
            Css.compile [ DateTimePicker.Css.css, DemoCss.css ]

        analogDateTimePickerConfig =
            let
                defaultDateTimeConfig =
                    defaultDateTimePickerConfig AnalogDateTimeChanged
            in
                { defaultDateTimeConfig | timePickerType = DateTimePicker.Config.Analog }

        digitalDateTimePickerConfig =
            let
                defaultDateTimeConfig =
                    defaultDateTimePickerConfig DateTimeChanged
            in
                { defaultDateTimeConfig | timePickerType = DateTimePicker.Config.Digital }
    in
        form []
            [ Html.node "style" [] [ Html.text css ]
            , div [ class [ Container ] ]
                [ p
                    []
                    [ label []
                        [ text "Date Picker: "
                        , DateTimePicker.datePicker
                            DateChanged
                            []
                            model.datePickerState
                            model.dateValue
                        ]
                    ]
                , p
                    []
                    [ label []
                        [ text "Digital Date Time Picker: "
                        , DateTimePicker.dateTimePickerWithConfig
                            digitalDateTimePickerConfig
                            []
                            model.dateTimePickerState
                            model.dateTimeValue
                        ]
                    ]
                , p
                    []
                    [ label []
                        [ text "Analog Date Time Picker: "
                        , DateTimePicker.dateTimePickerWithConfig
                            analogDateTimePickerConfig
                            []
                            model.analogDateTimePickerState
                            model.analogDateTimeValue
                        ]
                    ]
                , p []
                    [ ul []
                        [ li []
                            [ text "Date: ", text <| toString model.dateValue ]
                        , li []
                            [ p [] [ text "Date Time: ", text <| toString model.dateTimeValue ]
                            ]
                          -- , li []
                          --     [ text "Time: ", text <| toString model.timeValue ]
                        ]
                    ]
                ]
            ]


type Msg
    = NoOp
    | DateChanged DateTimePicker.State (Maybe Date)
    | DateTimeChanged DateTimePicker.State (Maybe Date)
    | AnalogDateTimeChanged DateTimePicker.State (Maybe Date)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DateChanged state value ->
            ( { model | dateValue = value, datePickerState = state }, Cmd.none )

        DateTimeChanged state value ->
            ( { model | dateTimeValue = value, dateTimePickerState = state }, Cmd.none )

        AnalogDateTimeChanged state value ->
            ( { model | analogDateTimeValue = value, analogDateTimePickerState = state }, Cmd.none )
