# Modified from /vendor/packages/x-editable/address.js

class OX.Profile.Name

  @defaults = $.extend({}, $.fn.editabletypes.abstractinput.defaults,
    tpl: '''
       <div><input type="text" name="title" class="form-control input-sm" data-l10n-id="profile-name-title"></div>
       <div><input type="text" name="first_name" class="form-control input-sm" data-l10n-id="profile-name-first-name"></div>
       <div><input type="text" name="last_name" class="form-control input-sm" data-l10n-id="profile-name-last-name"></div>
       <div><input type="text" name="suffix" class="form-control input-sm" data-l10n-id="profile-name-suffix"></div>
    '''
    inputclass: ''
  )

  constructor: (options) ->
    this.init('profile_name', options, OX.Profile.Name.defaults)

$.fn.editabletypes.profile_name = OX.Profile.Name
$.fn.editableutils.inherit(OX.Profile.Name, $.fn.editabletypes.abstractinput)
$.extend(OX.Profile.Name.prototype, {
  render: ->
    this.$input = this.$tpl.find('input')

  value2html: ->

  value2str: (value) ->
    str = ''
    if value
      for k of value
        str = str + k + ':' + value[k] + ';'
    str

  value2input: (value) ->
    return unless value
    this.$input.filter('[name="title"]').val value.title
    this.$input.filter('[name="first_name"]').val value.first_name
    this.$input.filter('[name="last_name"]').val value.last_name
    this.$input.filter('[name="suffix"]').val value.suffix

  input2value: ->
    {
      title: this.$input.filter('[name="title"]').val()
      first_name: this.$input.filter('[name="first_name"]').val()
      last_name: this.$input.filter('[name="last_name"]').val()
      suffix: this.$input.filter('[name="suffix"]').val()
    }

  activate: ->
    this.$input.filter('[name="first_name"]').focus()

  autosubmit: ->
    this.$input.keydown (e) ->
      $(this).closest('form').submit() if e.which is 13

})
