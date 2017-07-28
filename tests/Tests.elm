module Tests exposing (..)

import DateUtilsTests
import GeometryTests
import Test exposing (Test, describe)


all : Test
all =
    describe "All Test Suite"
        [ DateUtilsTests.all
        , GeometryTests.all
        ]
