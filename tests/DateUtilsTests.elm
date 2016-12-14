module DateUtilsTests exposing (..)

import Test exposing (..)
import Expect
import DatePicker.DateUtils as DateUtils
import Date
import Date.Extra.Create


-- TEST SUITE


all : Test
all =
    describe "DateUtils Test Suite"
        [ dayToIntTest
        , generateCalendarTest
        , toDateTest
        ]


dayToIntTest : Test
dayToIntTest =
    describe "DateUtils.dayToInt"
        [ test "dayToInt for Sunday when start of week is Sunday should return 0" <|
            \() ->
                DateUtils.dayToInt Date.Sun Date.Sun
                    |> Expect.equal 0
        , test "dayToInt for Friday when start of week is Sunday should return 0" <|
            \() ->
                DateUtils.dayToInt Date.Sun Date.Fri
                    |> Expect.equal 5
        , test "dayToInt for Sunday when start of week is Monday should return 0" <|
            \() ->
                DateUtils.dayToInt Date.Mon Date.Sun
                    |> Expect.equal 6
        , test "dayToInt for Sunday when start of week is Saturday should return 0" <|
            \() ->
                DateUtils.dayToInt Date.Sat Date.Sun
                    |> Expect.equal 1
        ]


generateCalendarTest : Test
generateCalendarTest =
    let
        current =
            DateUtils.Day DateUtils.Current

        previous =
            DateUtils.Day DateUtils.Previous

        next =
            DateUtils.Day DateUtils.Next
    in
        describe "DateUtil.generateCalendar"
            [ test "generateCalendar for February 2016 (leap) should return a list of date" <|
                \() ->
                    DateUtils.generateCalendar Date.Sun Date.Feb 2016
                        |> Expect.equal ([ previous 31 ] ++ (List.range 1 29 |> List.map current) ++ (List.range 1 12 |> List.map next))
            , test "generateCalendar for February 2015 should return a list of date" <|
                \() ->
                    DateUtils.generateCalendar Date.Sun Date.Feb 2015
                        |> Expect.equal ((List.range 25 31 |> List.map previous) ++ (List.range 1 28 |> List.map current) ++ (List.range 1 7 |> List.map next))
            , test "generateCalendar for January 2099 should return a list of date" <|
                \() ->
                    DateUtils.generateCalendar Date.Sun Date.Jan 2099
                        |> Expect.equal ((List.range 28 31 |> List.map previous) ++ (List.range 1 31 |> List.map current) ++ (List.range 1 7 |> List.map next))
            ]


toDateTest : Test
toDateTest =
    describe "DateUtils.toDate"
        [ test "toDate for January 2016 previous month should return the right date" <|
            \() ->
                DateUtils.toDate 2016 Date.Jan (DateUtils.Day DateUtils.Previous 29)
                    |> Expect.equal (Date.Extra.Create.dateFromFields 2015 Date.Dec 29 0 0 0 0)
        , test "toDate for December 2016 next month should return the right date" <|
            \() ->
                DateUtils.toDate 2016 Date.Dec (DateUtils.Day DateUtils.Next 2)
                    |> Expect.equal (Date.Extra.Create.dateFromFields 2017 Date.Jan 2 0 0 0 0)
        , test "toDate for Feb 2016 current month should return the right date" <|
            \() ->
                DateUtils.toDate 2016 Date.Feb (DateUtils.Day DateUtils.Current 14)
                    |> Expect.equal (Date.Extra.Create.dateFromFields 2016 Date.Feb 14 0 0 0 0)
        ]
