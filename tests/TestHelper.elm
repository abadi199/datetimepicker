module TestHelper
    exposing
        ( TestResult
        , attribute
        , clickDay
        , date
        , datePicker
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
import DateTimePicker.Config exposing (Config, DatePickerConfig, TimePickerConfig, defaultDatePickerConfig)
import Html exposing (Html)
import Html.Attributes
import Json.Encode as Json
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)


{-| The state of a datetimepicker
-}
type TestResult config
    = TestResult
        { config : Config config ( DateTimePicker.State, Maybe Date )
        , state : DateTimePicker.State
        , date : Maybe Date
        , view : Config config ( DateTimePicker.State, Maybe Date ) -> DateTimePicker.State -> Maybe Date -> Html ( DateTimePicker.State, Maybe Date )
        }


{-| Initialize a new DateTimePicker with no initial date selected.

  - `now`: the simulated current time in the test scenario
  - `value`: the intially-selected value

-}
datePicker : Date -> Maybe Date -> TestResult (DatePickerConfig {})
datePicker now initialValue =
    let
        help s d =
            TestResult
                { config = defaultDatePickerConfig (,)
                , state = s
                , date = d
                , view =
                    \config state date ->
                        DateTimePicker.datePickerWithConfig config [] state date
                }
    in
    help
        (DateTimePicker.initialStateWithToday now)
        initialValue


withConfig :
    (Config config ( DateTimePicker.State, Maybe Date )
     -> Config config ( DateTimePicker.State, Maybe Date )
    )
    -> TestResult config
    -> TestResult config
withConfig fn (TestResult t) =
    TestResult { t | config = fn t.config }


selection : TestResult config -> Maybe Date
selection (TestResult t) =
    t.date


{-| Simulate typing into the input field
-}
typeString : String -> TestResult config -> TestResult config
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
open : TestResult config -> TestResult config
open =
    simulate Event.focus [ tag "input" ]


{-| Simulate clicking a day in the date picker calendar
-}
clickDay : String -> TestResult config -> TestResult config
clickDay dayText =
    simulate Event.mouseDown
        [ tag "td"
        , attribute "aria-label" dayText
        ]


{-| Render the view of the datetimepicker with the given state,
and return a `Test.Html.Query.Single` of the resulting Html.
-}
render : TestResult config -> Query.Single (TestResult config)
render (TestResult t) =
    t.view
        t.config
        t.state
        t.date
        |> Html.map
            (\( state, date ) ->
                TestResult
                    { t
                        | state = state
                        , date = date
                    }
            )
        |> Query.fromHtml


simulate : ( String, Json.Value ) -> List Selector -> TestResult config -> TestResult config
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
