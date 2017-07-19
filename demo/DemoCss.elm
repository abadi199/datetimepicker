module DemoCss exposing (CssClasses(..), css)

import Css exposing (..)
import Css.Elements exposing (..)


css : Css.Stylesheet
css =
    Css.stylesheet
        []


type CssClasses
    = Container
