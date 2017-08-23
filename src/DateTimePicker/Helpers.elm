module DateTimePicker.Helpers exposing (Type(..), updateCurrentDate, updateTimeIndicator)

import Date exposing (Date)
import DateTimePicker.DateUtils
import DateTimePicker.Internal exposing (InternalState(..), Time, TimeIndicator(..))


type Type
    = DateType
    | DateTimeType
    | TimeType


updateCurrentDate : Type -> InternalState -> Maybe Date
updateCurrentDate pickerType (InternalState state) =
    let
        updatedDate =
            state.date

        updatedDateTime =
            case ( state.date, state.time.hour, state.time.minute, state.time.amPm ) of
                ( Just date, Just hour, Just minute, Just amPm ) ->
                    Just (DateTimePicker.DateUtils.setTime date hour minute amPm)

                _ ->
                    Nothing

        updatedTime =
            case ( state.time.hour, state.time.minute, state.time.amPm ) of
                ( Just hour, Just minute, Just amPm ) ->
                    Just (DateTimePicker.DateUtils.toTime hour minute amPm)

                _ ->
                    Nothing
    in
    case pickerType of
        DateType ->
            updatedDate

        DateTimeType ->
            updatedDateTime

        TimeType ->
            updatedTime


updateTimeIndicator : Maybe TimeIndicator -> Time -> Maybe TimeIndicator
updateTimeIndicator activeIndicator time =
    case ( activeIndicator, time.hour, time.minute, time.amPm ) of
        ( Just HourIndicator, _, Nothing, _ ) ->
            Just MinuteIndicator

        ( Just HourIndicator, _, Just _, Nothing ) ->
            Just AMPMIndicator

        ( Just HourIndicator, _, Just _, Just _ ) ->
            Nothing

        ( Just MinuteIndicator, _, _, Nothing ) ->
            Just AMPMIndicator

        ( Just MinuteIndicator, Nothing, _, Just _ ) ->
            Just HourIndicator

        ( Just MinuteIndicator, Just _, _, Just _ ) ->
            Nothing

        ( Just AMPMIndicator, Nothing, _, _ ) ->
            Just HourIndicator

        ( Just AMPMIndicator, Just _, Nothing, _ ) ->
            Just MinuteIndicator

        ( Just AMPMIndicator, Just _, Just _, _ ) ->
            Nothing

        ( Nothing, Nothing, _, _ ) ->
            Just HourIndicator

        ( Nothing, Just _, Nothing, _ ) ->
            Just MinuteIndicator

        ( Nothing, Just _, Just _, Nothing ) ->
            Just AMPMIndicator

        ( _, Just _, Just _, Just _ ) ->
            Nothing
