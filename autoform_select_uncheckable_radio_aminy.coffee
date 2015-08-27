AutoForm.addInputType "select-uncheckable-radio",
  template: "afUncheckableRadioGroup"
  valueOut: ->
    @find("input[type=radio]:checked").val()

  contextAdjust: (context) ->
    itemAtts = _.omit(context.atts)

    context.items = []
    # Add all defined options
    _.each context.selectOptions, (opt) ->
      context.items.push
        name: context.name
        label: opt.label
        value: opt.value

        # _id must be included because it is a special property that
        # #each uses to track unique list items when adding and removing them
        # See https://github.com/meteor/meteor/issues/2174
        _id: opt.value
        selected: (opt.value is context.value)
        atts: itemAtts
    context

Template.afUncheckableRadioGroup.helpers
  atts: selectedAttsAdjust = ->
    atts = _.clone(@atts)
    atts.checked = "" if @selected

    # Remove data-schema-key attribute because we put it on the entire group
    delete atts["data-schema-key"]

    atts
  dsk: dsk = ->
    "data-schema-key": @atts["data-schema-key"]
  active: ->
    console.log("lastValue: ", Template.instance().lastValue.get())
    if Template.instance().lastValue.get()
      'active'
    else
      ''
  higherSelected: (currentItem) ->
    console.log("currentItem", currentItem)
    console.log('lastvalue', Template.instance().lastValue.get())
    if Template.instance().lastValue.get()
      items = Template.instance().data.items
      higherSelected = ''
      foundSelf = false
      passedSelected = false
      _.each(_.clone(items).reverse(), (item) ->
        if passedSelected and (item is currentItem)
          foundSelf = true
        if item.value is Template.instance().lastValue.get()
          passedSelected = true
        if foundSelf and passedSelected
          higherSelected = "higherSelected"
      )
      higherSelected
    else
      # Nothing selected, use parent class to style
      ''

Template.afUncheckableRadioGroup.events
  'click label': (event, template) ->
    event.preventDefault()
    selected = $(event.currentTarget.parentNode).children('input')
    if template.lastValue.get() is selected.val()
      if not template.lastSameChecked
        selected.prop('checked', false)
        template.lastSameChecked = true
      else
        selected.prop('checked', true)
        template.lastSameChecked = false
    else
      selected.prop('checked', true).change()
    console.log('selectedVal', selected.val())
    if selected.is(':checked')
      console.log("is checked")
      template.lastValue.set(undefined) # Cheat to reactively .get() same value
      template.lastValue.set(selected.val())
    else
      console.log("is NOT checked")
      template.lastValue.set(undefined)
  'change input[type=radio]': (event, template) ->
    # Reset toggle variables
    template.lastValue.set(undefined)
    template.lastSameChecked = false

Template.afUncheckableRadioGroup.created = ->
  @lastValue = new ReactiveVar()
  @lastValue.set(@data.value) # On created, consider the radio just got selected
  @lastSameChecked = false

Template.afUncheckableRadioGroup.rendered = ->
  addAutoFormHooks(AutoForm.getFormId())

addAutoFormHooks = (formId) ->
  AutoForm.addHooks formId,
    before:
      update: (doc) ->
        # Need to unset fields that have previously been set
        ss = AutoForm.getFormSchema(formId)
        uncheckableRadioFieldKeys = []
        # Find all fields of type select-uncheckable-radio
        _.each(ss._schemaKeys, (key) ->
          if ss._schema[key].autoform?.type is "select-uncheckable-radio"
            uncheckableRadioFieldKeys.push(key)
        )
        doc.$unset = {}
        _.each(uncheckableRadioFieldKeys, (key) ->
          # Only unset undefined fields, i.e.: select-uncheckable-radio types which have just been unselected
          if not doc.$set[key]
            doc.$unset[key] = ""
        )
        @.result(doc)

Template.afUncheckableRadioGroup.copyAs('afUncheckableRadioGroup_materialize');
