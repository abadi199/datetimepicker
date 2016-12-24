module Tests exposing (..)

import Test exposing (Test, describe)
import DateUtilsTests
import GeometryTests


all : Test
all =
    describe "All Test Suite"
        [ DateUtilsTests.all
        , GeometryTests.all
        ]
