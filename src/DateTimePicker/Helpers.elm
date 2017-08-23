module DateTimePicker.Helpers exposing (Type(..), updateCurrentDate, updateTimeIndicator)

import Date exposing (Date)
import DateTimePicker.DateUtils
import DateTimePicker.Internal exposing (InternalState(..), TimeIndicator(..))


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


updateTimeIndicator : InternalState -> InternalState
updateTimeIndicator (InternalState state) =
    InternalState <|
        case ( state.activeTimeIndicator, state.time.hour, state.time.minute, state.time.amPm ) of
            ( Just HourIndicator, _, Nothing, _ ) ->
                { state | activeTimeIndicator = Just MinuteIndicator }

            ( Just HourIndicator, _, Just _, Nothing ) ->
                { state | activeTimeIndicator = Just AMPMIndicator }

            ( Just HourIndicator, _, Just _, Just _ ) ->
                { state | activeTimeIndicator = Nothing }

            ( Just MinuteIndicator, _, _, Nothing ) ->
                { state | activeTimeIndicator = Just AMPMIndicator }

            ( Just MinuteIndicator, Nothing, _, Just _ ) ->
                { state | activeTimeIndicator = Just HourIndicator }

            ( Just MinuteIndicator, Just _, _, Just _ ) ->
                { state | activeTimeIndicator = Nothing }

            ( Just AMPMIndicator, Nothing, _, _ ) ->
                { state | activeTimeIndicator = Just HourIndicator }

            ( Just AMPMIndicator, Just _, Nothing, _ ) ->
                { state | activeTimeIndicator = Just MinuteIndicator }

            ( Just AMPMIndicator, Just _, Just _, _ ) ->
                { state | activeTimeIndicator = Nothing }

            ( Nothing, Nothing, _, _ ) ->
                { state | activeTimeIndicator = Just HourIndicator }

            ( Nothing, Just _, Nothing, _ ) ->
                { state | activeTimeIndicator = Just MinuteIndicator }

            ( Nothing, Just _, Just _, Nothing ) ->
                { state | activeTimeIndicator = Just AMPMIndicator }

            ( _, Just _, Just _, Just _ ) ->
                { state | activeTimeIndicator = Nothing }
