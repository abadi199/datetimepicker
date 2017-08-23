module DateTimePicker.Helpers exposing (updateCurrentDate, updateTimeIndicator)

import Date exposing (Date)
import DateTimePicker.DateUtils
import DateTimePicker.Internal exposing (InternalState(..), Time, TimeIndicator(..))


updateCurrentDate : InternalState -> Maybe Date
updateCurrentDate (InternalState state) =
    case ( state.time.hour, state.time.minute, state.time.amPm ) of
        ( Just hour, Just minute, Just amPm ) ->
            Just (DateTimePicker.DateUtils.toTime hour minute amPm)

        _ ->
            Nothing


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
