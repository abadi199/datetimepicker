module TestHelper exposing (TestResult, init, open, render, selection, simulate, withConfig)

{-| This module provides functions that allow high-level test interactions with datetimepickers
-}

import Date exposing (Date)
import DateTimePicker
import DateTimePicker.Config exposing (Config, DatePickerConfig, defaultDatePickerConfig)
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

-}
init : Date -> TestResult
init now =
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
        Nothing


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


{-| Simulate opening the datetimpicker (by focusing the input field)
-}
open : TestResult -> TestResult
open =
    simulate Event.focus [ tag "input" ]


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
