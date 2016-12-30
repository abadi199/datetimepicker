module DateTimePicker.ClockUtils
    exposing
        ( hours
        , minutes
        , minutesPerFive
        , hourToAngle
        , minuteToAngle
        )

import Dict


hourToAngle : Int -> Maybe Float
hourToAngle hour =
    Dict.get (toString hour) hours


minuteToAngle : Int -> Maybe Float
minuteToAngle minute =
    Dict.get (toString minute) minutes



-- Hour Position


hours : Dict.Dict String Float
hours =
    Dict.fromList
        [ ( "1", pi * 2 / 6 )
        , ( "2", pi * 1 / 6 )
        , ( "3", pi * 2 )
        , ( "4", pi * 11 / 6 )
        , ( "5", pi * 10 / 6 )
        , ( "6", pi * 9 / 6 )
        , ( "7", pi * 8 / 6 )
        , ( "8", pi * 7 / 6 )
        , ( "9", pi )
        , ( "10", pi * 5 / 6 )
        , ( "11", pi * 4 / 6 )
        , ( "12", pi / 2 )
        ]


minutesPerFive : Dict.Dict String Float
minutesPerFive =
    Dict.fromList
        [ ( "5", pi * 2 / 6 )
        , ( "10", pi * 1 / 6 )
        , ( "15", pi * 2 )
        , ( "20", pi * 11 / 6 )
        , ( "25", pi * 10 / 6 )
        , ( "30", pi * 9 / 6 )
        , ( "35", pi * 8 / 6 )
        , ( "40", pi * 7 / 6 )
        , ( "45", pi )
        , ( "50", pi * 5 / 6 )
        , ( "55", pi * 4 / 6 )
        , ( "0", pi / 2 )
        ]


minutes : Dict.Dict String Float
minutes =
    List.range 0 59
        |> List.map (\minute -> ( toString minute, pi * toFloat (60 - ((45 + minute) % 60)) / 30 ))
        |> Dict.fromList
