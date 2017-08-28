module DateTimePicker.Internal
    exposing
        ( InternalState(..)
        , Time
        , TimeIndicator(..)
        , initialState
        , initialStateWithToday
        )

import Date exposing (Date)
import Date.Extra.Core


type InternalState
    = InternalState
        { inputFocused : Bool
        , forceClose : Bool
        , event : String
        , today : Maybe Date
        , titleDate : Maybe Date
        , date : Maybe Date
        , time : Time
        , hourPickerStart : Int
        , minutePickerStart : Int
        , currentAngle : Maybe Float
        , activeTimeIndicator : Maybe TimeIndicator
        }


type TimeIndicator
    = HourIndicator
    | MinuteIndicator
    | AMPMIndicator


type alias Time =
    { hour : Maybe Int, minute : Maybe Int, amPm : Maybe String }


initialState : InternalState
initialState =
    InternalState
        { inputFocused = False
        , forceClose = False
        , event = ""
        , today = Nothing
        , titleDate = Nothing
        , date = Nothing
        , time = Time Nothing Nothing Nothing
        , hourPickerStart = 1
        , minutePickerStart = 0
        , currentAngle = Nothing
        , activeTimeIndicator = Just HourIndicator
        }


initialStateWithToday : Date -> InternalState
initialStateWithToday today =
    InternalState
        { inputFocused = False
        , forceClose = False
        , event = ""
        , today = Just today
        , titleDate = Just <| Date.Extra.Core.toFirstOfMonth today
        , date = Nothing
        , time = Time Nothing Nothing Nothing
        , hourPickerStart = 1
        , minutePickerStart = 0
        , currentAngle = Nothing
        , activeTimeIndicator = Just HourIndicator
        }
