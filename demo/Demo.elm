module Demo exposing (main)

import Css
import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format
import DateParser
import DateTimePicker
import DateTimePicker.Config exposing (Config, DatePickerConfig, TimePickerConfig, defaultDatePickerConfig, defaultDateTimeI18n, defaultDateTimePickerConfig, defaultTimePickerConfig)
import DateTimePicker.Css
import DemoCss exposing (CssClasses(..))
import Html exposing (Html, div, form, label, li, p, text, ul)
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
    , customI18nValue : Maybe Date
    , customI18nPickerState : DateTimePicker.State
    , timeValue : Maybe Date
    , timePickerState : DateTimePicker.State
    , noPickerValue : Maybe Date
    , noPickerPickerState : DateTimePicker.State
    }


init : ( Model, Cmd Msg )
init =
    ( { dateValue = Nothing
      , datePickerState = DateTimePicker.initialState
      , dateTimeValue = Nothing
      , dateTimePickerState = DateTimePicker.initialState
      , analogDateTimeValue = Nothing
      , analogDateTimePickerState = DateTimePicker.initialState
      , customI18nValue = Nothing
      , customI18nPickerState = DateTimePicker.initialState
      , timeValue = Nothing
      , timePickerState = DateTimePicker.initialState
      , noPickerValue = Nothing
      , noPickerPickerState = DateTimePicker.initialState
      }
    , Cmd.batch
        [ DateTimePicker.initialCmd DateChanged DateTimePicker.initialState
        , DateTimePicker.initialCmd DateTimeChanged DateTimePicker.initialState
        , DateTimePicker.initialCmd AnalogDateTimeChanged DateTimePicker.initialState
        , DateTimePicker.initialCmd CustomI18Changed DateTimePicker.initialState
        , DateTimePicker.initialCmd TimeChanged DateTimePicker.initialState
        , DateTimePicker.initialCmd NoPickerChanged DateTimePicker.initialState
        ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


{ id, class, classList } =
    Html.CssHelpers.withNamespace ""


analogDateTimePickerConfig : Config (DatePickerConfig TimePickerConfig) Msg
analogDateTimePickerConfig =
    let
        defaultDateTimeConfig =
            defaultDateTimePickerConfig AnalogDateTimeChanged
    in
    { defaultDateTimeConfig
        | timePickerType = DateTimePicker.Config.Analog
        , allowYearNavigation = False
    }


timePickerConfig : Config TimePickerConfig Msg
timePickerConfig =
    let
        defaultDateTimeConfig =
            defaultTimePickerConfig TimeChanged
    in
    { defaultDateTimeConfig
        | timePickerType = DateTimePicker.Config.Analog
    }


noPickerConfig : Config (DatePickerConfig {}) Msg
noPickerConfig =
    let
        defaultDateConfig =
            defaultDatePickerConfig NoPickerChanged
    in
    { defaultDateConfig
        | usePicker = False
        , attributes = [ class [ "Test" ] ]
    }


customI18nConfig : Config (DatePickerConfig TimePickerConfig) Msg
customI18nConfig =
    let
        defaultDateTimeConfig =
            defaultDateTimePickerConfig CustomI18Changed
    in
    { defaultDateTimeConfig
        | timePickerType = DateTimePicker.Config.Analog
        , allowYearNavigation = False
        , i18n = { defaultDateTimeI18n | inputFormat = customInputFormat }
    }


customDatePattern : String
customDatePattern =
    "%d/%m/%Y %H:%M"


customInputFormat : DateTimePicker.Config.InputFormat
customInputFormat =
    { inputFormatter = Date.Extra.Format.format config customDatePattern
    , inputParser = DateParser.parse config customDatePattern >> Result.toMaybe
    }


digitalDateTimePickerConfig : Config (DatePickerConfig TimePickerConfig) Msg
digitalDateTimePickerConfig =
    let
        defaultDateTimeConfig =
            defaultDateTimePickerConfig DateTimeChanged
    in
    { defaultDateTimeConfig
        | timePickerType = DateTimePicker.Config.Digital
    }


digitalTimePickerConfig : Config TimePickerConfig Msg
digitalTimePickerConfig =
    let
        defaultDateTimeConfig =
            defaultTimePickerConfig TimeChanged
    in
    { defaultDateTimeConfig
        | timePickerType = DateTimePicker.Config.Digital
    }


view : Model -> Html Msg
view model =
    let
        { css } =
            Css.compile [ DateTimePicker.Css.css, DemoCss.css ]
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
            , p
                []
                [ label []
                    [ text "Custom i18n: "
                    , DateTimePicker.dateTimePickerWithConfig
                        customI18nConfig
                        []
                        model.customI18nPickerState
                        model.customI18nValue
                    ]
                ]
            , p
                []
                [ label []
                    [ text "Time Picker: "
                    , DateTimePicker.timePickerWithConfig
                        digitalTimePickerConfig
                        []
                        model.timePickerState
                        model.timeValue
                    ]
                ]
            , p
                []
                [ label []
                    [ text "No Picker: "
                    , DateTimePicker.datePickerWithConfig
                        noPickerConfig
                        []
                        model.noPickerPickerState
                        model.noPickerValue
                    ]
                ]
            , p []
                [ ul []
                    [ li []
                        [ text "Date: ", text <| toString model.dateValue ]
                    , li []
                        [ text "Digital Date Time: ", text <| toString model.dateTimeValue ]
                    , li []
                        [ text "Analog Date Time: ", text <| toString model.analogDateTimeValue ]
                    , li []
                        [ text "Custom i18n: ", text <| toString model.customI18nValue ]
                    , li []
                        [ text "Time: ", text <| toString model.timeValue ]
                    ]
                ]
            ]
        ]


type Msg
    = NoOp
    | DateChanged DateTimePicker.State (Maybe Date)
    | DateTimeChanged DateTimePicker.State (Maybe Date)
    | AnalogDateTimeChanged DateTimePicker.State (Maybe Date)
    | CustomI18Changed DateTimePicker.State (Maybe Date)
    | TimeChanged DateTimePicker.State (Maybe Date)
    | NoPickerChanged DateTimePicker.State (Maybe Date)


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

        CustomI18Changed state value ->
            ( { model | customI18nValue = value, customI18nPickerState = state }, Cmd.none )

        TimeChanged state value ->
            ( { model | timeValue = value, timePickerState = state }, Cmd.none )

        NoPickerChanged state value ->
            ( { model | noPickerValue = value, noPickerPickerState = state }, Cmd.none )
