module DatePickerDialogTests exposing (all)

import Date exposing (Date)
import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag)
import TestHelper exposing (attribute, clickDay, date, init, open, render, selection, typeString)


now : Date
now =
    -- 2017-08-11T22:30:55Z
    Date.fromTime 1502490656000


all : Test
all =
    describe "datePicker dialog"
        [ test "initial value is Nothing" <|
            \() ->
                init now Nothing
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" ""
                        ]
        , test "initial value is a date" <|
            \() ->
                init now (Just <| date 2017 8 29 0 0)
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" "08/29/2017"
                        ]
        , test "initial value is a date with a time" <|
            \() ->
                init now (Just <| date 2017 8 29 23 59)
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" "08/29/2017"
                        ]
        , test "typing a date" <|
            \() ->
                init now Nothing
                    |> typeString "08/14/2017"
                    |> selection
                    |> Expect.equal (Just <| date 2017 8 14 0 0)
        , test "typing an invalid date" <|
            \() ->
                init now Nothing
                    |> typeString "WOWEP"
                    |> selection
                    |> Expect.equal Nothing
        , test "clearing the input" <|
            \() ->
                init now (Just <| date 2017 8 1 0 0)
                    |> typeString ""
                    |> selection
                    |> Expect.equal Nothing
        , test "selecting a date" <|
            \() ->
                init now Nothing
                    |> open
                    |> clickDay "13, Sunday August 2017"
                    |> selection
                    |> Expect.equal (Just <| date 2017 8 13 0 0)
        ]
