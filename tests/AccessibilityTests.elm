module AccessibilityTests exposing (..)

import Date exposing (Date)
import Html.Attributes
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)
import TestHelper exposing (init, open, render)


now : Date
now =
    -- 2017-08-11T22:30:55Z
    Date.fromTime 1502490656000


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
                    |> Query.has
                        [ tag "td"
                        , attribute "aria-label" "15, Tuesday August 2017"
                        ]
        ]


attribute : String -> String -> Selector
attribute attr value =
    Test.Html.Selector.attribute <| Html.Attributes.attribute attr value
