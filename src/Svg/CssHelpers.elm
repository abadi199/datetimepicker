module Svg.CssHelpers exposing (Namespace, withNamespace)

import Css.Helpers exposing (identifierToString, toCssIdentifier)
import String
import Svg exposing (Attribute, Svg)
import Svg.Attributes as Attr
import Tuple


type alias Namespace name class id msg =
    { class : List class -> Attribute msg
    , classList : List ( class, Bool ) -> Attribute msg
    , id : id -> Attribute msg
    , name : name
    }


withNamespace : name -> Namespace name class id msg
withNamespace name =
    { class = namespacedClass name
    , classList = namespacedClassList name
    , id = toCssIdentifier >> Attr.id
    , name = name
    }


namespacedClassList : name -> List ( class, Bool ) -> Attribute msg
namespacedClassList name list =
    list
        |> List.filter Tuple.second
        |> List.map Tuple.first
        |> namespacedClass name


namespacedClass : name -> List class -> Attribute msg
namespacedClass name list =
    list
        |> List.map (identifierToString name)
        |> String.join " "
        |> Attr.class
