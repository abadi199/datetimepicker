module GeometryTests exposing (..)

import Test exposing (..)
import Expect
import DateTimePicker.Geometry as Geometry exposing (Point)


all : Test
all =
    describe "Geometry Tests Suite"
        [ calculateAngleTests
        , calculateArrowPointTests
        ]


calculateAngleTests : Test
calculateAngleTests =
    describe "Geometry.calculateAngle"
        [ test "calculateAngle for pi/6" <|
            \() ->
                Geometry.calculateAngle (Point 0 0) (Point 100 0) (Point 100 100)
                    |> Expect.equal 5.497787143782138
        , test "calculateAngle for 09:00" <|
            \() ->
                Geometry.calculateAngle (Point 100 100) (Point 200 100) (Point 200 100)
                    |> Expect.equal 6.283185307179586
        ]


calculateArrowPointTests : Test
calculateArrowPointTests =
    describe "Geometry.calculateArrowPoint"
        [ test "calculateArrowPoint for 12:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi / 2)
                    |> Expect.equal (Point 100 0)
        , test "calculateArrowPoint for 1:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 2 / 6)
                    |> Expect.equal (Point 150 13)
        , test "calculateArrowPoint for 2:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 1 / 6)
                    |> Expect.equal (Point 187 50)
        , test "calculateArrowPoint for 3:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 12 / 6)
                    |> Expect.equal (Point 200 100)
        , test "calculateArrowPoint for 4:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 11 / 6)
                    |> Expect.equal (Point 187 150)
        , test "calculateArrowPoint for 5:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 10 / 6)
                    |> Expect.equal (Point 150 187)
        , test "calculateArrowPoint for 6:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 9 / 6)
                    |> Expect.equal (Point 100 200)
        , test "calculateArrowPoint for 7:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 8 / 6)
                    |> Expect.equal (Point 50 187)
        , test "calculateArrowPoint for 8:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 7 / 6)
                    |> Expect.equal (Point 13 150)
        , test "calculateArrowPoint for 9:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi)
                    |> Expect.equal (Point 0 100)
        , test "calculateArrowPoint for 10:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 5 / 6)
                    |> Expect.equal (Point 13 50)
        , test "calculateArrowPoint for 11:00" <|
            \() ->
                Geometry.calculateArrowPoint (Point 100 100) 100 (pi * 4 / 6)
                    |> Expect.equal (Point 50 13)
        ]
