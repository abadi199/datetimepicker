module DateTimePicker.Events
    exposing
        ( onBlurWithChange
        , onMouseDownPreventDefault
        , onMouseUpPreventDefault
        , onMouseMoveWithPosition
        , onPointerMoveWithPosition
        , onTouchStartPreventDefault
        , onTouchEndPreventDefault
        , onTouchMovePreventDefault
        , onPointerUp
        , MoveData
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


onTouchStartPreventDefault : msg -> Html.Attribute msg
onTouchStartPreventDefault msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "touchstart" eventOptions (Json.Decode.succeed msg)


onMouseUpPreventDefault : msg -> Html.Attribute msg
onMouseUpPreventDefault msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "mouseup" eventOptions (Json.Decode.succeed msg)


onTouchEndPreventDefault : msg -> Html.Attribute msg
onTouchEndPreventDefault msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "touchend" eventOptions (Json.Decode.succeed msg)


onMouseMoveWithPosition : (MoveData -> Json.Decode.Decoder msg) -> Svg.Attribute msg
onMouseMoveWithPosition decoder =
    Svg.Events.on "mousemove"
        (mouseMoveDecoder |> Json.Decode.andThen (decoder))


onPointerMoveWithPosition : (MoveData -> Json.Decode.Decoder msg) -> Svg.Attribute msg
onPointerMoveWithPosition decoder =
    Html.Events.on "pointermove"
        (mouseMoveDecoder |> Json.Decode.andThen (decoder))


onPointerUp : msg -> Html.Attribute msg
onPointerUp msg =
    Html.Events.on "pointerup" (Json.Decode.succeed msg)


onTouchMovePreventDefault : msg -> Svg.Attribute msg
onTouchMovePreventDefault msg =
    let
        eventOptions =
            { preventDefault = True
            , stopPropagation = True
            }
    in
        Html.Events.onWithOptions "touchstart"
            eventOptions
            (Json.Decode.succeed msg)


type alias MoveData =
    { offsetX : Int, offsetY : Int }


mouseMoveDecoder : Json.Decode.Decoder MoveData
mouseMoveDecoder =
    Json.Decode.map2 MoveData
        (Json.Decode.field "offsetX" Json.Decode.int)
        (Json.Decode.field "offsetY" Json.Decode.int)


touches : Json.Decode.Decoder a -> Json.Decode.Decoder (List a)
touches decoder =
    let
        loop idx xs =
            Json.Decode.maybe (Json.Decode.field (toString idx) decoder)
                |> Json.Decode.andThen
                    (Maybe.map (\x -> loop (idx + 1) (x :: xs))
                        >> Maybe.withDefault (Json.Decode.succeed xs)
                    )
    in
        Json.Decode.at [ "touches", "0" ] <| loop 0 []
