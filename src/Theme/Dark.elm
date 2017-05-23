module Theme.Dark exposing (themeConfiguration)

import Css exposing (..)


themeConfiguration =
    { highlight =
        [ property "box-shadow" "inset 0 0 10px 3px #3276b1"
        , backgroundColor (hex "#428bca")
        , color (hex "#fff")
        ]
    , headerFooter =
        { background = hex "#242424"
        , foreground = hex "#f5f5f5"
        , hover = hex "#444444"
        , border = hex "#000"
        }
    , body =
        { background = hex "#555555"
        , foreground = hex "#f5f5f5"
        , hover = hex "#777777"
        , border = hex "#000"
        }
    }
