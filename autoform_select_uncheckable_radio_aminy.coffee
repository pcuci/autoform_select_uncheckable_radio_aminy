AutoForm.addInputType "select-uncheckable-radio",
  template: "afUncheckableRadioGroup"
  valueOut: ->
    console.log("VALUE OUT ------------ VALUE OUT, this", @)
    console.log("VALUE OUT ------------ VALUE OUT", @find("input[type=radio]:checked").val())
    @find("input[type=radio]:checked").val()

  contextAdjust: (context) ->
    console.log("context", context)
    console.log("this.data", Template.currentData())
    ss = AutoForm.getFormSchema()
    console.log("ss", ss._schema[context.name].label)

    label = ss._schema[context.name].label
    # Split on new lines to 3 different lines
    lines = label.split("\n")
    context.firstLine = if lines[0] then lines[0] else ""
    context.firstSubLine = if lines[1] then lines[1] else ""
    context.secondSubLine = if lines[2] then lines[2] else ""
    itemAtts = _.omit(context.atts)
    console.log("itemAtts", itemAtts)

    context.items = []
    # Add all defined options
    firstPass = true
    _.each context.selectOptions, (opt) ->
      lines = opt.label.split("\n")
      firstLine = if lines[0] then lines[0] else ""
      firstSubLine = if lines[1] then lines[1] else ""
      secondSubLine = if lines[2] then lines[2] else ""
      context.items.push
        name: context.name
        firstLine: firstLine
        firstSubLine: firstSubLine
        secondSubLine: secondSubLine
        value: opt.value

        # _id must be included because it is a special property that
        # #each uses to track unique list items when adding and removing them
        # See https://github.com/meteor/meteor/issues/2174
        _id: opt.value
        selected: (opt.value is context.value)
        atts: itemAtts
    context

Template.afUncheckableRadioGroup.helpers
  atts: ->
    atts = _.clone(@atts)

    atts.checked = "" if @selected

    if @selected
      console.log("Selected -------------------", @selected)
    # Remove data-schema-key attribute because we put it on the entire group
    delete atts["data-schema-key"]
    console.log("atts", atts)
    atts
  dsk: ->
    "data-schema-key": @atts["data-schema-key"]
  active: ->
    if Template.currentData().currentValue?.get()
      'active'
    else
      ''
  isActive: ->
    if Template.currentData().currentValue?.get()
      true
    else
      false

Template.afUncheckableRadioGroup.events
  'click input + label': (event, template) ->
    console.log("tmpl data:", template.data)
    event.preventDefault()
    selected = $(event.currentTarget.parentNode).children('input')
    console.log("selected value: ", selected.val())
    template.data.currentValue.set(undefined)
    template.data.currentValue.set(selected.val())
    if template.data.lastValue.get() is selected.val()
      if not template.data.lastSameChecked
        selected.prop('checked', false)
        template.data.lastSameChecked = true
        template.data.currentValue.set(undefined)
      else
        selected.prop('checked', true)
        template.data.lastSameChecked = false
    else
      selected.prop('checked', true).change()
    if selected.is(':checked')
      template.data.lastValue.set(undefined) # Cheat to reactively .get() same value
      template.data.lastValue.set(selected.val())
    else
      template.data.lastValue.set(undefined)
  'change input[type=radio]': (event, template) ->
    console.log("changed!!!!!!!!!changed!!!!!!!!!changed!!!!!!!!!changed!!!!!!!!!changed!!!!!!!!!")
    # Reset toggle variables
    template.data.lastValue.set(undefined)
    template.data.lastSameChecked = false
  'click p.fieldLabel': (event, template) ->
    template.data.value = template.data.items[0].value
    console.log("currentValue", template.data.currentValue.get())
    template.data.currentValue.set(template.data.items[0].value)
    template.data.lastValue.set(undefined)
    template.data.lastSameChecked = false
    console.log("lastValue", template.data.lastValue.get())
    console.log("currentValue", template.data.currentValue.get())

Template.afUncheckableRadioGroupActiveRadio.helpers
  higherSelected: (currentItem) ->
    # console.log("currentData(): ", Template.currentData())
    # console.log("parentData(0): ", Template.parentData(0))
    # console.log("parentData(1): ", Template.parentData(1))
    # console.log("parentData(2): ", Template.parentData(2))
    if Template.parentData().currentValue?.get()
      console.log("currentValue in higherSelected", Template.parentData(1).currentValue.get())

    if Template.parentData(1).currentValue?.get()
      items = Template.parentData(1).items
      higherSelected = ''
      foundSelf = false
      passedSelected = false
      _.each(_.clone(items).reverse(), (item) ->
        if passedSelected and (item is currentItem)
          foundSelf = true
        if item.value is Template.parentData(1).lastValue.get()
          passedSelected = true
        if foundSelf and passedSelected
          higherSelected = "higherSelected"
      )
      higherSelected
    else
      # Nothing selected, use parent class to style
      ''
Template.afUncheckableRadioGroupActiveRadios.rendered = ->
  console.log("Active Radios rendered =------------------------------------             xxxx")
  console.log("this afUncheckableRadioGroupActiveRadios", this)
  $(@find('input[type=radio]')).prop('checked', true).change()
  console.log("checked?", @find('input[type=radio]'))
  console.log("parentData() - activeradios", Template.parentData(0))
  Template.parentData(0).value = Template.parentData(0).items[0].value
  Template.parentData(0).currentValue.set(undefined)
  Template.parentData(0).currentValue.set(Template.parentData(0).items[0].value)
  console.log("parentData() - activeradios", Template.parentData(0))


Template.afUncheckableRadioGroup.created = ->
  @data.lastValue = new ReactiveVar(@data.value) # On created, consider the radio just got selected
  @data.currentValue = new ReactiveVar(@data.value)
  @data.lastSameChecked = false
  console.log("this -- created:", @)

Template.afUncheckableRadioGroup.rendered = ->
  addAutoFormHooks(AutoForm.getFormId())

addAutoFormHooks = (formId) ->
  AutoForm.addHooks formId,
    before:
      update: (doc) ->
        console.log("                       --- before updateDOC", doc)
        console.log("                       >>> Field valu", AutoForm.getFieldValue())
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
#Template.afUncheckableRadioGroupActiveRadios.copyAs('afUncheckableRadioGroupActiveRadios_materialize');
#Template.afUncheckableRadioGroupActiveRadio.copyAs('afUncheckableRadioGroupActiveRadio_materialize');


Template.autoForm.onRendered(->
  # console.log("in autoform rendered")
  # spans = $('span.spanText')
  # console.log("span.spanTexts", spans)
  # console.log(".parentNode.parentNode.parentNode.clientWidth", spans[3].parentNode.parentNode.parentNode.clientWidth)
  # console.log(".parentNode.parentNode.offsetLeft", spans[3].parentNode.parentNode.offsetLeft)
  # offset = spans[3].parentNode.parentNode.parentNode.clientWidth - spans[3].clientWidth
  # console.log('parent:', $(spans[3].parentNode.parentNode.parentNode))
  # $(spans[3]).offset({left: (-1 * offset)})
)
