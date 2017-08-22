module TimePickerDialogTests exposing (all)

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
    describe "timePicker dialog"
        [ test "initial value is Nothing" <|
            \() ->
                timePicker now Nothing
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" ""
                        ]
        , test "initial value is a time" <|
            \() ->
                timePicker now (Just <| date 1970 1 1 13 58)
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" "01:58 PM"
                        ]
        , test "initial value is a date with a time" <|
            \() ->
                timePicker now (Just <| date 2017 8 29 23 59)
                    |> render
                    |> Query.has
                        [ tag "input"
                        , attribute "value" "11:59 PM"
                        ]
        , test "typing a time" <|
            \() ->
                timePicker now Nothing
                    |> typeString "04:13 AM"
                    |> selection
                    |> Expect.equal (Just <| date 1900 1 1 4 13)
        , test "typing an invalid time" <|
            \() ->
                timePicker now Nothing
                    |> typeString "WOWEP"
                    |> selection
                    |> Expect.equal Nothing
        , test "clearing the input" <|
            \() ->
                timePicker now (Just <| date 1970 1 1 12 16)
                    |> typeString ""
                    |> selection
                    |> Expect.equal Nothing
        , test "selecting a time" <|
            \() ->
                timePicker now Nothing
                    |> withConfig (\c -> { c | timePickerType = Digital })
                    |> open
                    |> clickHour 4
                    |> clickMinute 1
                    |> clickPM
                    |> selection
                    |> Expect.equal (Just <| date 0 1 1 16 1)
        ]
