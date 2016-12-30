module DigitalDateTimePickerDemo exposing (main)

import Html exposing (Html, text, p, label, form, ul, li, div)
import Html.Attributes exposing (autocomplete)
import DateTimePicker
import DateTimePicker.Config exposing (defaultDatePickerConfig, defaultDateTimePickerConfig)
import Date exposing (Date)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    { selectedDate : Maybe Date
    , datePickerState : DateTimePicker.State
    }


init : ( Model, Cmd Msg )
init =
    ( { selectedDate = Nothing
      , datePickerState = DateTimePicker.initialState
      }
    , Cmd.batch
        [ DateTimePicker.initialCmd DateChange DateTimePicker.initialState
        ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    let
        default =
            DateTimePicker.Config.defaultDateTimePickerConfig DateChange

        config =
            { default | timePickerType = DateTimePicker.Config.Digital }
    in
        form []
            [ p
                []
                [ label []
                    [ text "Digital Date Time Picker: "
                    , DateTimePicker.dateTimePickerWithConfig
                        config
                        [ autocomplete False ]
                        model.datePickerState
                        model.selectedDate
                    ]
                ]
            , p []
                [ text <| "Selected Date and Time: " ++ (Maybe.withDefault "Nothing" <| Maybe.map toString model.selectedDate)
                ]
            ]


type Msg
    = NoOp
    | DateChange DateTimePicker.State (Maybe Date)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DateChange state value ->
            ( { model | selectedDate = value, datePickerState = state }, Cmd.none )
