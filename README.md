# Date and Time Picker

## Demo

### [Live Demo](https://abadi199.github.io/datetimepicker/)

### Date Time Picker

The date and time picker can be used in two modes:

* Analog Time Picker
* Digital Time Picker

#### Analog time picker

![alt text](https://github.com/abadi199/datetimepicker/raw/master/images/datetimepicker-analog.gif "Date Time Picker with Analog Time Picker Preview")

Code:

```elm
view model =
    DateTimePicker.dateTimePickerWithConfig
        { defaultDateTimeConfig | timePickerType = DateTimePicker.Config.Analog }
        [ class "my-datetimepicker" ]
        model.state
        model.value
```

### Digital time picker

![alt text](https://github.com/abadi199/datetimepicker/raw/master/images/datetimepicker-digital.gif "Date Time Picker with Digital Time Picker Preview")

Code:

```elm
view model =
    DateTimePicker.dateTimePickerWithConfig
        { defaultDateTimeConfig | timePickerType = DateTimePicker.Config.Digital }
        [ class "my-datetimepicker" ]
        model.state
        model.value
```

### Date Picker

Just the date picker without the time.

![alt text](https://github.com/abadi199/datetimepicker/raw/master/images/datepicker.gif "Date Picker Preview")

Code:

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

### Time Picker

Just the time picker without the date.

![alt text](https://github.com/abadi199/datetimepicker/raw/master/images/timepicker.gif "Time Picker Preview")

Code:

```elm
type Msg = TimeChange DateTimePicker.State (Maybe Date)

type alias Model = { value : Maybe Date, state : DateTimePicker.State }

view model =
    DateTimePicker.timePicker
        TimeChange
        [ class "my-timepicker" ]
        model.state
        model.value
```

## Documentation

This package follows the `evancz\sortable-table` package approach where it's not
a nested elm architecture 'component'. It's just view functions where you feed
the data and the message constructor to the function. It does use an opaque
`State` to maintain its internal state.

The picker requires the initial value of the date (usually today) to set the
initial position of the calendar. To feed this date to the picker's internal
state, you can use 2 approaches

* By passing a `Date` value to the `DateTimePicker.initialStateWithToday`
  function when initialing the picker's State.
* By calling the `DateTimePicker.initialCmd` as part of your `init` commands.

### Views

The date time picker package provides multiple view functions, depending on how
you want to use the picker.

* `datePicker` is a simple date picker view, with no time picker, and comes with
  all default configuration.
* `timePicker` is a simple time picker view, with no date picker, and comes with
  all default configuration.
* `dateTimePicker` is a simple date and time picker view, comes with all default
  configuration.
* `datePickerWithConfig` is a configurable date picker view.
* `timePickerWithConfig` is a configurable time picker view.
* `dateTimePickerWithConfig` is a configurable date and time picker view.

### Config

You customize the date picker configuration by passing a
`DateTimePicker.Config.Config` value to the picker's view function. The
DateTimePicker.Config module provides some default configurations for both date
picker and date time picker.

## Internationalization

In order to localize your date format, you need to provide the date time picker
with a `Date` to `String` formatter and `String` to `Maybe Date` parser. The
author recommends using
[rluiten/elm-date-extra](package.elm-lang.org/packages/rluiten/elm-date-extra/latest)
for the formatter, and
[abadi199/dateparser](http://package.elm-lang.org/packages/abadi199/dateparser/latest)
for the parser.

### CSS

The
[rtfeldman/elm-css](http://package.elm-lang.org/packages/rtfeldman/elm-css/latest)
code for this package is available as separate package as
[abadi199/datetimepicker-css](http://package.elm-lang.org/packages/abadi199/datetimepicker-css/latest),
that way, you can still use package without having to have dependency to elm-css
or if your project is using different version of `elm-css`. Just the download
compiled
[`styles.css`](https://raw.githubusercontent.com/abadi199/datetimepicker-css/master/styles.css)
in include it in your `html`. If you're using `elm-css` in your project, and you
want to bundle the DateTimePicker's css along with our project css, please refer
to
[abadi199/datetimepicker-css](http://package.elm-lang.org/packages/abadi199/datetimepicker-css/latest)

### Example

Here's a snippet of typical Elm application:

```elm
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type Msg
    = DateChange DateTimePicker.State (Maybe Date)

type alias Model =
    { selectedDate : Maybe Date
    , datePickerState : DateTimePicker.State
    }

init =
    ( { selectedDate = Nothing, datePickerState = DateTimePicker.initialState }
    , DateTimePicker.initialCmd DateChange DateTimePicker.initialState
    )

view model =
    DateTimePicker.dateTimePickerWithConfig
        DateChange
        [ class "my-datetimepicker" ]
        model.datePickerState
        model.selectedDate

update msg model =
    case msg of
        DateChange datePickerState selectedDate ->
            ( { model | selectedDate = selectedDate, datePickerState = datePickerState }, Cmd.none )

subscriptions =
    ...
```

For a complete sample code, please see the
[demo](https://github.com/abadi199/datetimepicker/tree/master/demo) folder of
the source code.

## Contributing

* [Submit a pull request](https://github.com/abadi199/datetimepicker)! If you're
  missing a feature you want to have, or just found a bug, or found an error in
  the docs, please submit a pull request.
* [Create an issue](https://github.com/abadi199/datetimepicker/issues)! If you
  found a bug or want a new feature that you think will make the library better,
  but don't have time to do it yourself, please submit an issue.
* Message me on slack or [twitter](https://twitter.com/abadikurniawan) if you
  just want to give me a feedback or thank me. I'm
  [abadi199](https://elmlang.slack.com/team/abadi199) on
  [elm-lang](https://elmlang.herokuapp.com/) slack channel.
