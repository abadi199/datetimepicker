module AccessibilityTests exposing (..)

import Date exposing (Date)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag)
import TestHelper exposing (attribute, datePicker, open, render)


now : Date
now =
    -- 2017-08-11T22:30:55Z
    Date.fromTime 1502490656000


datePickerTests : Test
datePickerTests =
    describe "date picker accessibility"
        [ test "date cells should have role=button" <|
            \() ->
                datePicker now Nothing
                    |> open
                    |> render
                    |> Query.findAll [ tag "td" ]
                    |> Query.each
                        (Query.has [ attribute "role" "button" ])
        , test "date cells should have labels" <|
            \() ->
                datePicker now Nothing
                    |> open
                    |> render
                    |> Query.has
                        [ tag "td"
                        , attribute "aria-label" "15, Tuesday August 2017"
                        ]
        ]
