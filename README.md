# Date and Time Picker

### [Live Demo]()

For a complete sample code, please see the [demo](https://github.com/abadi199/datetimepicker/tree/master/demo) folder of the source code.

Date and Time Picker written entirely in Elm. This date time picker can be configured to work in multiple ways.

## Date Time Picker

Date and time picker.

### Analog time picker

Preview:

![alt text](https://github.com/abadi199/datetimepicker/raw/master/images/datetimepicker-analog.gif "Date Time Picker with Analog Time Picker Preview")

Example:
```elm
type Msg = DateChange DateTimePicker.State (Maybe Date)

type alias Model = { value : Maybe Date, state : DateTimePicker.State }

config = 
    let
        defaultDateTimeConfig =
            DateTimePicker.defaultDateTimePickerConfig DateChange
    in
        { defaultDateTimeConfig | timePickerType = DateTimePicker.Config.Analog }

view model =
    DateTimePicker.dateTimePickerWithConfig
        config
        [ class "my-datetimepicker" ]
        model.state
        model.value
```

### Digital time picker

Preview:

![alt text](https://github.com/abadi199/datetimepicker/raw/master/images/datetimepicker-digital.gif "Date Time Picker with Digital Time Picker Preview")

Example:
```elm
type Msg = DateChange DateTimePicker.State (Maybe Date)

type alias Model = { value : Maybe Date, state : DateTimePicker.State }

config = 
    let
        defaultDateTimeConfig =
            DateTimePicker.defaultDateTimePickerConfig DateChange
    in
        { defaultDateTimeConfig | timePickerType = DateTimePicker.Config.Digital }

view model =
    DateTimePicker.dateTimePickerWithConfig
        config
        [ class "my-datetimepicker" ]
        model.state
        model.value
```


Date Picker
---
Just the date picker without the time.

Preview:

![alt text](https://github.com/abadi199/datetimepicker/raw/master/images/datepicker.gif "Date Picker Preview")

Example:
```elm
type Msg = DateChange DateTimePicker.State (Maybe Date)

type alias Model = { value : Maybe Date, state : DateTimePicker.State }

view model =
    DateTimePicker.datePicker
        DateChange
        [ class "my-datepicker" ]
        model.state
        model.value
```
Feedback and PR are welcome :)