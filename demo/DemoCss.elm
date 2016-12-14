module DemoCss exposing (css, CssClasses(..))

import Css exposing (..)
import Css.Elements exposing (..)


css : Css.Stylesheet
css =
    (Css.stylesheet)
        [ (.) Container [ displayFlex, children [ p [ width (em 30) ] ] ] ]


type CssClasses
    = Container
