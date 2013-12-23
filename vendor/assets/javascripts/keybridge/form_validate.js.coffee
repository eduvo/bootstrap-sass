###
Usage:

1. Requires this module, "utils/form_validate".
2. Add `data-validate="true"` attribute to the specific form tag.
###
define (require) ->
  require 'jquery.h5validate'

  bind = (form) ->
    form.h5Validate()
    form.on('validated', (e, o) ->
      # Success
      if o.valid
        el = $(o.element)
        el.closest('.validate-group').removeClass('error')
        # TODO - We shouldn't remove all help-inline under .validate-group
        el.closest('.validate-group').find('span.help-inline').remove()
        return
      # Normalizes error messages.
      e.preventDefault()
      group = $(o.element).closest('.validate-group')
      group.addClass('error')
      controls = group.find('.controls')
      label = group.find('.control-label').text().replace('*', '')
      if o.valueMissing
        message = "#{label} field is required"
      else if o.patternMismatch
        message = "The format of #{label} field is not matched"
      # Update to container.
      help = group.find('.help-inline')
      if help.length > 0
        help.text(message)
      else
        controls.append('<span class="help-inline">' + message + '</span>')
    )
    form.on('submit', (e) ->
      e.preventDefault() if $(@).find('.validate-group.error').length
    )

  forms = $('form')
  forms.each (i, form) ->
    form = $(form)
    bind(form) if form.data('validate') && form.data('validate') == true
