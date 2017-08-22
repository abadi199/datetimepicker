module TestHelper
    exposing
        ( TestResult
        , attribute
        , clickDay
        , date
        , init
        , open
        , render
        , selection
        , simulate
        , typeString
        , withConfig
        )

{-| This module provides functions that allow high-level test interactions with datetimepickers
-}

import Date exposing (Date)
import Date.Extra.Core
import Date.Extra.Create
import DateTimePicker
import DateTimePicker.Config exposing (Config, DatePickerConfig, defaultDatePickerConfig)
import Html.Attributes
import Json.Encode as Json
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)


{-| The state of a datetimepicker
-}
type TestResult
    = TestResult
        { config : Config (DatePickerConfig {}) TestResult
        , state : DateTimePicker.State
        , date : Maybe Date
        }


{-| Initialize a new DateTimePicker with no initial date selected.

  - `now`: the simulated current time in the test scenario
  - `value`: the intially-selected value

-}
init : Date -> Maybe Date -> TestResult
init now initialValue =
    let
        help s d =
            TestResult
                { config = defaultDatePickerConfig help
                , state = s
                , date = d
                }
    in
    help
        (DateTimePicker.initialStateWithToday now)
        initialValue


withConfig : (Config (DatePickerConfig {}) TestResult -> Config (DatePickerConfig {}) TestResult) -> TestResult -> TestResult
withConfig fn (TestResult t) =
    let
        newConfig =
            fn t.config
    in
    TestResult { t | config = newConfig }


selection : TestResult -> Maybe Date
selection (TestResult t) =
    t.date


{-| Simulate typing into the input field
-}
typeString : String -> TestResult -> TestResult
typeString string =
    simulate
        ( "blur"
        , Json.object
            [ ( "target"
              , Json.object
                    [ ( "value", Json.string string )
                    ]
              )
            ]
        )
        [ tag "input" ]


{-| Simulate opening the datetimpicker (by focusing the input field)
-}
open : TestResult -> TestResult
open =
    simulate Event.focus [ tag "input" ]


{-| Simulate clicking a day in the date picker calendar
-}
clickDay : String -> TestResult -> TestResult
clickDay dayText =
    simulate Event.mouseDown
        [ tag "td"
        , attribute "aria-label" dayText
        ]


{-| Render the view of the datetimepicker with the given state,
and return a `Test.Html.Query.Single` of the resulting Html.
-}
render : TestResult -> Query.Single TestResult
render (TestResult t) =
    DateTimePicker.datePickerWithConfig
        t.config
        []
        t.state
        t.date
        |> Query.fromHtml


simulate : ( String, Json.Value ) -> List Selector -> TestResult -> TestResult
simulate event selector (TestResult t) =
    render (TestResult t)
        |> Query.find selector
        |> Event.simulate event
        |> Event.toResult
        |> (\r ->
                case r of
                    Err message ->
                        Debug.crash message

                    Ok result ->
                        result
           )


{-| This is for convienience in testing Html attributes
-}
attribute : String -> String -> Selector
attribute attr value =
    Test.Html.Selector.attribute <| Html.Attributes.attribute attr value


{-| Concise way to make a date in tests
-}
date : Int -> Int -> Int -> Int -> Int -> Date
date year month day hour minute =
    Date.Extra.Create.dateFromFields
        year
        (Date.Extra.Core.intToMonth month)
        day
        hour
        minute
        0
        0
