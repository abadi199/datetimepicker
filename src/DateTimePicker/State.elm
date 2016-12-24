module DateTimePicker.State
    exposing
        ( InternalState(..)
        , StateValue
        , Time
        , getStateValue
        )

import Date exposing (Date)
import DateTimePicker.Geometry exposing (Point)


type InternalState
    = InternalState StateValue


type alias StateValue =
    { inputFocused : Bool
    , forceClose : Bool
    , event : String
    , today : Maybe Date
    , titleDate : Maybe Date
    , date : Maybe Date
    , time : Time
    , hourPickerStart : Int
    , minutePickerStart : Int
    , clockMousePosition : Maybe Point
    }


type alias Time =
    { hour : Maybe Int, minute : Maybe Int, amPm : Maybe String }


{-| Get the internal state values
-}
getStateValue : InternalState -> StateValue
getStateValue state =
    case state of
        InternalState stateValue ->
            stateValue
