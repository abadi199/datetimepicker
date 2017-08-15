module TestHelper exposing (TestResult, init, open, render)

{-| This module provides functions that allow high-level test interactions with datetimepickers
-}

import Date exposing (Date)
import DateTimePicker
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)


{-| The state of a datetimepicker
-}
type alias TestResult =
    ( DateTimePicker.State, Maybe Date )


{-| Initialize a new DateTimePicker with no initial date selected.

  - `now`: the simulated current time in the test scenario

-}
init : Date -> TestResult
init now =
    ( DateTimePicker.initialStateWithToday now
    , Nothing
    )


{-| Simulate opening the datetimpicker (by focusing the input field)
-}
open : TestResult -> TestResult
open ( oldState, selection ) =
    DateTimePicker.datePicker
        (,)
        []
        oldState
        Nothing
        |> Query.fromHtml
        |> Query.find [ tag "input" ]
        |> Event.simulate Event.focus
        |> Event.toResult
        |> (\result ->
                case result of
                    Err message ->
                        Debug.crash ("Can't open datetimepicker:" ++ message)

                    Ok ( state, date ) ->
                        ( state, date )
           )


{-| Render the view of the datetimepicker with the given state,
and return a `Test.Html.Query.Single` of the resulting Html.
-}
render : TestResult -> Query.Single ()
render ( state, date ) =
    DateTimePicker.datePicker
        (\_ _ -> ())
        []
        state
        Nothing
        |> Query.fromHtml
