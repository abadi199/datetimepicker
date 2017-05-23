module Theme.Light exposing (themeConfiguration)

import Css exposing (..)


themeConfiguration =
    { highlight =
        [ property "box-shadow" "inset 0 0 10px 3px #3276b1"
        , backgroundColor (hex "#428bca")
        , color (hex "#fff")
        ]
    , headerFooter =
        { background = hex "#f5f5f5"
        , foreground = hex "#555555"
        , hover = hex "#f5f5f5"
        , border = hex "#ccc"
        }
    , body =
        { background = hex "#ffffff"
        , foreground = hex "#555555"
        , hover = hex "#ebebeb"
        , border = hex "#ccc"
        }
    }
