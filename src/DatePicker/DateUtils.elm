module DatePicker.DateUtils
    exposing
        ( dayToInt
        , generateCalendar
        , Day
        , MonthType(..)
        , toDate
        , padding
        )

import Date
import Date.Extra.Create
import Date.Extra.Core
import String


dayToInt : Date.Day -> Date.Day -> Int
dayToInt startOfWeek day =
    let
        base =
            case day of
                Date.Sun ->
                    0

                Date.Mon ->
                    1

                Date.Tue ->
                    2

                Date.Wed ->
                    3

                Date.Thu ->
                    4

                Date.Fri ->
                    5

                Date.Sat ->
                    6
    in
        case startOfWeek of
            Date.Sun ->
                base

            Date.Mon ->
                (base - 1) % 7

            Date.Tue ->
                (base - 2) % 7

            Date.Wed ->
                (base - 3) % 7

            Date.Thu ->
                (base - 4) % 7

            Date.Fri ->
                (base - 5) % 7

            Date.Sat ->
                (base - 6) % 7


calculateNumberOfDaysForPreviousMonth : Int -> Int
calculateNumberOfDaysForPreviousMonth firstDayInInt =
    if firstDayInInt == 0 then
        7
    else
        firstDayInInt


type alias Day =
    { monthType : MonthType, day : Int }


type MonthType
    = Previous
    | Current
    | Next


generateCalendar : Date.Day -> Date.Month -> Int -> List Day
generateCalendar firstDayOfWeek month year =
    let
        firstDateOfMonth =
            Date.Extra.Create.dateFromFields year month 1 0 0 0 0

        firstDayOfMonth =
            firstDateOfMonth
                |> Date.dayOfWeek
                |> dayToInt firstDayOfWeek

        numberOfDaysForPreviousMonth =
            calculateNumberOfDaysForPreviousMonth firstDayOfMonth

        daysInMonth =
            Date.Extra.Core.daysInMonthDate firstDateOfMonth

        daysInPreviousMonth =
            Date.Extra.Core.daysInPrevMonth firstDateOfMonth

        previousMonth =
            List.range (daysInPreviousMonth - numberOfDaysForPreviousMonth + 1) daysInPreviousMonth
                |> List.map (Day Previous)

        currentMonth =
            List.range 1 daysInMonth
                |> List.map (Day Current)

        nextMonth =
            List.range 1 14
                |> List.map (Day Next)
    in
        List.take 42 <| previousMonth ++ currentMonth ++ nextMonth


toDate : Int -> Date.Month -> Day -> Date.Date
toDate year month day =
    case day.monthType of
        Current ->
            Date.Extra.Create.dateFromFields year month day.day 0 0 0 0

        Previous ->
            let
                previousMonth =
                    Date.Extra.Create.dateFromFields year month day.day 0 0 0 0
                        |> Date.Extra.Core.lastOfPrevMonthDate
            in
                Date.Extra.Create.dateFromFields (Date.year previousMonth) (Date.month previousMonth) day.day 0 0 0 0

        Next ->
            let
                nextMonth =
                    Date.Extra.Create.dateFromFields year month day.day 0 0 0 0
                        |> Date.Extra.Core.firstOfNextMonthDate
            in
                Date.Extra.Create.dateFromFields (Date.year nextMonth) (Date.month nextMonth) day.day 0 0 0 0


padding : String -> String
padding str =
    if String.length str == 0 then
        "00"
    else if String.length str == 1 then
        "0" ++ str
    else
        str
