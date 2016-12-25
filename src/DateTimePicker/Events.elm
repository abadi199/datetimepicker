module DateTimePicker.Events
    exposing
        ( onBlurWithChange
        , onMouseDownPreventDefault
        , onMouseUpPreventDefault
        , onMouseOverWithPosition
        , MouseMoveData
        )

import Date exposing (Date)
import Html
import Html.Events
import Json.Decode
import Svg.Events
import Svg


onBlurWithChange : (Maybe Date -> msg) -> Html.Attribute msg
onBlurWithChange tagger =
    Html.Events.on "blur"
        (Json.Decode.map (Date.fromString >> Result.toMaybe >> tagger) Html.Events.targetValue)


onMouseDownPreventDefault : msg -> Html.Attribute msg
onMouseDownPreventDefault msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "mousedown" eventOptions (Json.Decode.succeed msg)


onMouseUpPreventDefault : msg -> Html.Attribute msg
onMouseUpPreventDefault msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "mouseup" eventOptions (Json.Decode.succeed msg)


onMouseOverWithPosition : (MouseMoveData -> Json.Decode.Decoder msg) -> Svg.Attribute msg
onMouseOverWithPosition decoder =
    Svg.Events.on "mousemove"
        (mouseMoveDecoder |> Json.Decode.andThen (decoder))


type alias MouseMoveData =
    { offsetX : Int, offsetY : Int }


mouseMoveDecoder : Json.Decode.Decoder MouseMoveData
mouseMoveDecoder =
    Json.Decode.map2 MouseMoveData
        (Json.Decode.field "offsetX" Json.Decode.int)
        (Json.Decode.field "offsetY" Json.Decode.int)
