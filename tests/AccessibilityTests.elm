module AccessibilityTests exposing (..)

import Date exposing (Date)
import DateTimePicker
import Html.Attributes
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)


now : Date
now =
    -- 2017-08-11T22:30:55Z
    Date.fromTime 1502490656000


type alias TestResult =
    ( DateTimePicker.State, Maybe Date )


init : Date -> TestResult
init now =
    ( DateTimePicker.initialStateWithToday now
    , Nothing
    )


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


render : TestResult -> Query.Single ()
render ( state, date ) =
    DateTimePicker.datePicker
        (\_ _ -> ())
        []
        state
        Nothing
        |> Query.fromHtml


datePickerTests : Test
datePickerTests =
    describe "date picker accessibility"
        [ test "date cells should have role=button" <|
            \() ->
                init now
                    |> open
                    |> render
                    |> Query.findAll [ tag "td" ]
                    |> Query.each
                        (Query.has [ attribute "role" "button" ])
        , test "date cells should have labels" <|
            \() ->
                init now
                    |> open
                    |> render
                    |> Query.has [ tag "td", attribute "aria-label" "15, Tuesday August 2017" ]
        ]


attribute : String -> String -> Selector
attribute attr value =
    Test.Html.Selector.attribute <| Html.Attributes.attribute attr value
