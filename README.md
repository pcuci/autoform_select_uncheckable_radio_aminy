# Materialize Theme for Uncheckable Radios Autoform Field
Ever wanted to undo a radio button selection inside a form? I mean really undo, as in un-select, de-select, unchek the radio button as if it was never selected

Now you can!

### Note
Field must be `optional: true` - obviously!

```coffeescript
@radioOptions = ["opt1", "opt2", "opt3"]

Topics.attachSchema new SimpleSchema(
  feelingGood:
    type: String
    label: "Good"
    allowedValues: radioOptions
    optional: true
    autoform:
      type: "select-uncheckable-radio"
      options: ->
        _.map radioOptions, (option) ->
          {
            label: option
            value: option
          }
```
