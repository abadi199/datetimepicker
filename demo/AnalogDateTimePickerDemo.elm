module AnalogDateTimePickerDemo exposing (main)

import Html exposing (Html, text, p, label, form, ul, li, div)
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
    form []
        [ p
            []
            [ label []
                [ text "Analog Date Time Picker: "
                , DateTimePicker.dateTimePicker
                    DateChange
                    []
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
