module DateTimePickerDialogTests exposing (all)

import Date exposing (Date)
import DateTimePicker.Config exposing (TimePickerType(Digital))
import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag)
import TestHelper exposing (..)


now : Date
now =
    -- 2017-08-11T22:30:55Z
    Date.fromTime 1502490656000


all : Test
all =
    describe "dateTimePicker dialog"
        [ test "initial value is Nothing" <|
            \() ->
                dateTimePicker now Nothing
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" ""
                        ]
        , test "initial value is a date and time" <|
            \() ->
                dateTimePicker now (Just <| date 2017 8 29 9 13)
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" "08/29/2017 09:13 AM"
                        ]
        , test "typing a date and time" <|
            \() ->
                dateTimePicker now Nothing
                    |> typeString "08/15/2017 02:55 PM"
                    |> selection
                    |> Expect.equal (Just <| date 2017 8 15 14 55)
        , test "typing an invalid date" <|
            \() ->
                dateTimePicker now Nothing
                    |> typeString "WOWEP"
                    |> selection
                    |> Expect.equal Nothing
        , test "clearing the input" <|
            \() ->
                dateTimePicker now (Just <| date 2017 8 1 0 0)
                    |> typeString ""
                    |> selection
                    |> Expect.equal Nothing
        , test "selecting a date but no time yet" <|
            \() ->
                dateTimePicker now Nothing
                    |> open
                    |> clickDay "13, Sunday August 2017"
                    |> selection
                    |> Expect.equal Nothing
        , test "selecting a time but no date yet" <|
            \() ->
                dateTimePicker now Nothing
                    |> withConfig (\c -> { c | timePickerType = Digital })
                    |> open
                    |> clickHour 1
                    |> clickMinute 2
                    |> clickAM
                    |> selection
                    |> Expect.equal Nothing
        , test "selecting a date and a time" <|
            \() ->
                dateTimePicker now Nothing
                    |> withConfig (\c -> { c | timePickerType = Digital })
                    |> open
                    |> clickDay "13, Sunday August 2017"
                    |> clickHour 1
                    |> clickMinute 2
                    |> clickAM
                    |> selection
                    |> Expect.equal (Just <| date 2017 8 13 1 2)
        ]
