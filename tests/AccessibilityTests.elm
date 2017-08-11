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


open : DateTimePicker.State -> DateTimePicker.State
open oldState =
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
                        state
           )


render : DateTimePicker.State -> Query.Single ()
render state =
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
                DateTimePicker.initialStateWithToday now
                    |> open
                    |> render
                    |> Query.findAll [ tag "td" ]
                    |> Query.each
                        (Query.has [ attribute <| Html.Attributes.attribute "role" "button" ])
        ]
