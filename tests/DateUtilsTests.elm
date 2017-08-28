module DateUtilsTests exposing (..)

import Date
import Date.Extra.Create
import DateTimePicker.DateUtils as DateUtils
import Expect
import Test exposing (..)


-- TEST SUITE


all : Test
all =
    describe "DateUtils Test Suite"
        [ dayToIntTest
        , generateCalendarTest
        , toDateTest
        , toTimeTest
        , setTimeTest
        , paddingTest
        , fromMillitaryHourTest
        , fromMillitaryAmPmTest
        , toMillitaryTest
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


toTimeTest : Test
toTimeTest =
    describe "DateUtils.toTime"
        [ test "toTime for 12:00 AM should return the right time" <|
            \() ->
                DateUtils.toTime 12 0 "AM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 0 Date.Jan 1 0 0 0 0)
        , test "toTime for 12:00 PM should return the right time" <|
            \() ->
                DateUtils.toTime 12 0 "PM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 0 Date.Jan 1 12 0 0 0)
        , test "toTime for 3:15 PM should return the right time" <|
            \() ->
                DateUtils.toTime 3 15 "PM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 0 Date.Jan 1 15 15 0 0)
        , test "toTime for 3:15 AM should return the right time" <|
            \() ->
                DateUtils.toTime 3 15 "AM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 0 Date.Jan 1 3 15 0 0)
        ]


setTimeTest : Test
setTimeTest =
    let
        date =
            Date.Extra.Create.dateFromFields 2017 Date.Jan 1 0 0 0 0
    in
    describe "DateUtils.setTime"
        [ test "setTime for 12:00 AM should return the right time" <|
            \() ->
                DateUtils.setTime date 12 0 "AM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 2017 Date.Jan 1 0 0 0 0)
        , test "setTime for 12:00 PM should return the right time" <|
            \() ->
                DateUtils.setTime date 12 0 "PM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 2017 Date.Jan 1 12 0 0 0)
        , test "setTime for 3:15 PM should return the right time" <|
            \() ->
                DateUtils.setTime date 3 15 "PM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 2017 Date.Jan 1 15 15 0 0)
        , test "setTime for 3:15 AM should return the right time" <|
            \() ->
                DateUtils.setTime date 3 15 "AM"
                    |> Expect.equal (Date.Extra.Create.dateFromFields 2017 Date.Jan 1 3 15 0 0)
        ]


paddingTest : Test
paddingTest =
    describe "DateUtils.padding"
        [ test "padding 1 will return 01" <|
            \() ->
                DateUtils.padding "1"
                    |> Expect.equal "01"
        , test "padding empty string will return 00" <|
            \() ->
                DateUtils.padding ""
                    |> Expect.equal "00"
        , test "padding 12 will return 12" <|
            \() ->
                DateUtils.padding "12"
                    |> Expect.equal "12"
        ]


fromMillitaryHourTest : Test
fromMillitaryHourTest =
    describe "DateUtils.fromMillitaryHour"
        [ test "fromMillitaryHour 12 will return 12" <|
            \() ->
                DateUtils.fromMillitaryHour 12
                    |> Expect.equal 12
        , test "fromMillitaryHour 13 will return 1" <|
            \() ->
                DateUtils.fromMillitaryHour 13
                    |> Expect.equal 1
        , test "fromMillitaryHour 24 will return 12" <|
            \() ->
                DateUtils.fromMillitaryHour 0
                    |> Expect.equal 12
        , test "fromMillitaryHour 23 will return 11" <|
            \() ->
                DateUtils.fromMillitaryHour 23
                    |> Expect.equal 11
        ]


fromMillitaryAmPmTest : Test
fromMillitaryAmPmTest =
    describe "DateUtils.fromMillitaryAmPm"
        [ test "fromMillitaryAmPm 12 will return PM" <|
            \() ->
                DateUtils.fromMillitaryAmPm 12
                    |> Expect.equal "PM"
        , test "fromMillitaryAmPm 0 will return AM" <|
            \() ->
                DateUtils.fromMillitaryAmPm 0
                    |> Expect.equal "AM"
        , test "fromMillitaryAmPm 13 will return PM" <|
            \() ->
                DateUtils.fromMillitaryAmPm 13
                    |> Expect.equal "PM"
        , test "fromMillitaryAmPm 1 will return AM" <|
            \() ->
                DateUtils.fromMillitaryAmPm 1
                    |> Expect.equal "AM"
        , test "fromMillitaryAmPm 23 will return PM" <|
            \() ->
                DateUtils.fromMillitaryAmPm 23
                    |> Expect.equal "PM"
        ]


toMillitaryTest : Test
toMillitaryTest =
    describe "DateUtils.toMillitary"
        [ test "toMillitary 12 AM will return 0" <|
            \() ->
                DateUtils.toMillitary 12 "AM"
                    |> Expect.equal 0
        , test "toMillitary 12 PM will return 12" <|
            \() ->
                DateUtils.toMillitary 12 "PM"
                    |> Expect.equal 12
        , test "toMillitary 9 AM will return 9" <|
            \() ->
                DateUtils.toMillitary 9 "AM"
                    |> Expect.equal 9
        , test "toMillitary 2 PM will return 14" <|
            \() ->
                DateUtils.toMillitary 2 "PM"
                    |> Expect.equal 14
        ]
