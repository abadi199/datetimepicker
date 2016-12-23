module DatePickerDemo exposing (main)

import Html exposing (Html, text, p, label, form, ul, li, div)
import DatePicker exposing (defaultDatePickerConfig, defaultDateTimePickerConfig)
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
    { dateValue : Maybe Date
    , datePickerState : DatePicker.State
    , dateTimeValue : Maybe Date
    , dateTimePickerState : DatePicker.State
    , timeValue : Maybe Date
    , timePickerState : DatePicker.State
    }


init : ( Model, Cmd Msg )
init =
    ( { dateValue = Nothing
      , datePickerState = DatePicker.initialState
      , dateTimeValue = Nothing
      , dateTimePickerState = DatePicker.initialState
      , timeValue = Nothing
      , timePickerState = DatePicker.initialState
      }
    , Cmd.batch
        [ DatePicker.initialCmd DateChanged DatePicker.initialState
        , DatePicker.initialCmd DateTimeChanged DatePicker.initialState
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
            Css.compile [ DatePicker.Css.css, DemoCss.css ]
    in
        form []
            [ Html.node "style" [] [ Html.text css ]
            , div [ class [ Container ] ]
                [ p
                    []
                    [ label []
                        [ text "Date Picker: "
                        , DatePicker.datePicker
                            DateChanged
                            []
                            model.datePickerState
                            model.dateValue
                        ]
                    ]
                , p
                    []
                    [ label []
                        [ text "Meeting Start: "
                        , DatePicker.dateTimePicker
                            DateTimeChanged
                            []
                            model.dateTimePickerState
                            model.dateTimeValue
                        ]
                    ]
                  -- , p
                  --     []
                  --     [ label []
                  --         [ text "Time Picker: "
                  --         , DatePicker.timePicker
                  --             timePickerConfig
                  --             []
                  --             model.timePickerState
                  --             model.timeValue
                  --         ]
                  --     ]
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
    | DateChanged DatePicker.State (Maybe Date)
    | DateTimeChanged DatePicker.State (Maybe Date)
    | TimeChanged DatePicker.State (Maybe Date)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        DateChanged state value ->
            ( { model | dateValue = value, datePickerState = state }, Cmd.none )

        DateTimeChanged state value ->
            ( { model | dateTimeValue = value, dateTimePickerState = state }, Cmd.none )

        TimeChanged state value ->
            ( { model | timeValue = value, timePickerState = state }, Cmd.none )
