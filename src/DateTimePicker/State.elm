module DateTimePicker.State
    exposing
        ( InternalState(..)
        , StateValue
        , Time
        , TimeIndicator(..)
        , getStateValue
        , initialStateValue
        , initialStateValueWithToday
        )

import Date exposing (Date)
import DateTimePicker.Geometry exposing (Point)
import Date.Extra.Core


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
    , activeTimeIndicator : Maybe TimeIndicator
    }


type TimeIndicator
    = HourIndicator
    | MinuteIndicator
    | AMPMIndicator


type alias Time =
    { hour : Maybe Int, minute : Maybe Int, amPm : Maybe String }


initialStateValue : StateValue
initialStateValue =
    { inputFocused = False
    , forceClose = False
    , event = ""
    , today = Nothing
    , titleDate = Nothing
    , date = Nothing
    , time = Time Nothing Nothing Nothing
    , hourPickerStart = 1
    , minutePickerStart = 0
    , clockMousePosition = Nothing
    , activeTimeIndicator = Just HourIndicator
    }


initialStateValueWithToday : Date -> StateValue
initialStateValueWithToday today =
    { inputFocused = False
    , forceClose = False
    , event = ""
    , today = Just today
    , titleDate = Just <| Date.Extra.Core.toFirstOfMonth today
    , date = Nothing
    , time = Time Nothing Nothing Nothing
    , hourPickerStart = 1
    , minutePickerStart = 0
    , clockMousePosition = Nothing
    , activeTimeIndicator = Just HourIndicator
    }


{-| Get the internal state values
-}
getStateValue : InternalState -> StateValue
getStateValue state =
    case state of
        InternalState stateValue ->
            stateValue
