module Tests exposing (..)

import Test exposing (Test, describe)
import DateUtilsTests


all : Test
all =
    describe "All Test Suite"
        [ DateUtilsTests.all
        ]
