module Theme.Dark exposing (themeConfiguration)

import Css exposing (..)


themeConfiguration =
    { highlight =
        [ property "box-shadow" "inset 0 0 10px 3px #3276b1"
        , backgroundColor (hex "#428bca")
        , color (hex "#fff")
        ]
    , backgroundColor = hex "#151515"
    , foregroundColor = hex "#f5f5f5"
    }
