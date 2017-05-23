module RandomDate exposing (main)

import Css
import Date exposing (Date)
import DateTimePicker
import DateTimePicker.Config exposing (defaultDatePickerConfig, defaultDateTimePickerConfig)
import DateTimePicker.Css
import DateTimePicker.Theme as Theme
import DemoCss exposing (CssClasses(..))
import Html exposing (Html, button, div, form, label, li, p, text, ul)
import Html.Attributes exposing (type_)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Json.Decode
import Random


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
    }


init : ( Model, Cmd Msg )
init =
    ( { dateValue = Nothing
      , datePickerState = DateTimePicker.initialState
      }
    , Cmd.batch
        [ DateTimePicker.initialCmd DateChanged DateTimePicker.initialState
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
            Css.compile [ DateTimePicker.Css.css Theme.Dark, DemoCss.css ]

        analogDateTimePickerConfig =
            let
                defaultDateTimeConfig =
                    defaultDateTimePickerConfig DateChanged
            in
            { defaultDateTimeConfig | timePickerType = DateTimePicker.Config.Digital, allowYearNavigation = False }
    in
    form []
        [ Html.node "style" [] [ Html.text css ]
        , div [ class [ Container ] ]
            [ p
                []
                [ label []
                    [ text "Date Picker: "
                    , DateTimePicker.dateTimePickerWithConfig
                        analogDateTimePickerConfig
                        []
                        model.datePickerState
                        model.dateValue
                    ]
                ]
            ]
        , button [ type_ "button", onClick GetRandomDate ] [ text "Random Date" ]
        ]


type Msg
    = NoOp
    | DateChanged DateTimePicker.State (Maybe Date)
    | GetRandomDate
    | GetRandomDateCompleted (Maybe Date)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DateChanged state value ->
            ( { model | dateValue = value, datePickerState = state }, Cmd.none )

        GetRandomDate ->
            ( model, getRandomDate )

        GetRandomDateCompleted randomDate ->
            ( { model | dateValue = randomDate }, Cmd.none )


getRandomDate : Cmd Msg
getRandomDate =
    let
        dateGenerator =
            Random.float 10000000 1000000000000000
                |> Random.map (Date.fromTime >> Just)
    in
    Random.generate GetRandomDateCompleted dateGenerator
