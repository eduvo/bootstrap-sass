define (require) ->

  # Constants
  BODY_SELECTOR    = '.dropform'
  IN_CLASS         = 'in'
  COLLAPSED_CLASS  = 'collapsed'
  TOGGLE_SELECTOR  = '[data-toggle=dropform]'
  WRAPPER_SELECTOR = '.dropform-group'

  class Dropform
    constructor: (@element, @options) ->

    align: (align = 'center') ->
      $el = $(@)
      if body = $el.data('target')
        $body = $(body)
        position = $el.position()
        $body.css
          'left': position['left'] - $body.width() / 2 + $el.outerWidth() / 2 +  'px',
          'top' : position['top'] + $el.outerHeight() + 7 + 'px'
      else
        $body = $el.closest(WRAPPER_SELECTOR).find(BODY_SELECTOR)
        align = 'center' unless align in ['left', 'right', 'center']
        $el.data('align', align)
        $body.removeClass('left right center').addClass(align)
        switch align
          when 'center'
            $body.css
              'left' : -($body.outerWidth() / 2 - $el.outerWidth() / 2) + 'px',
              'top'  : $el.outerHeight() + 10 + 'px'
          when 'right'
            $body.css
              'right': '0'
              'top'  : $el.outerHeight() + 10 + 'px'
          when 'left'
            $body.css
              'left' : '0'
              'top'  : $el.outerHeight() + 10 + 'px'

    toggle: (e) ->
      $el = $(@)
      if body = $el.data('target')
        $body = $(body)
      else
        # Checks if it has required wrapper.
        wrapper = $el.closest(WRAPPER_SELECTOR)
        return if wrapper.length == 0
        # Checks if it has required body.
        body = $(wrapper[0]).find(BODY_SELECTOR)
        return if body.length == 0
        # Check if it is disabled.
        return if $el.prop('disabled')
        # Toggles the form
        $body = $(body)
      active = $body.hasClass(IN_CLASS)
      if active
        $el.trigger 'hide'
        $el.removeClass(COLLAPSED_CLASS)
        $body.removeClass(IN_CLASS)
        $el.trigger 'hidden'
      else
        $el.trigger 'show'
        $el.addClass(COLLAPSED_CLASS)
        $body.addClass(IN_CLASS)
        $el.trigger 'shown'
        align = $el.data('align')
        Dropform::align.call(@, align)
      if e
        e.preventDefault()
        e.stopPropagation()

  keydown = (e) ->
    $('.dropform').removeClass('in') if e.keyCode == 27 # ESC Keycode

  hideForms = (e) ->
    $el = $(e.target)
    return if $el.parents('.dropform').length
    $el.trigger 'hide.dropform'
    $('[data-toggle=dropform]').removeClass(COLLAPSED_CLASS)
    $('.dropform').removeClass(IN_CLASS)
    $el.trigger 'hidden.dropform'

  # Creates Dropform Plugin
  $.fn.dropform = (option) ->
    @.each ->
      $that = $(@)
      data = $that.data('dropform')
      # Initializes a new Dropform.
      if (!data)
        data = new Dropform(@)
        $that.data('dropform', data)
      # Executes a method.
      data[option].call($that) if (typeof option == 'string')

  $.fn.dropform.Constructor = Dropform

  old = $.fn.dropform
  $.fn.dropform.noConflict = ->
    $.fn.dropform = old
    @

  # Lazy way to make dropform taking effects.
  # It doesn't create any instance.
  $(document)
    .on("click#{WRAPPER_SELECTOR}", TOGGLE_SELECTOR, Dropform::toggle)
    .on("click#{WRAPPER_SELECTOR}", hideForms)
    .on("keydown#{WRAPPER_SELECTOR}", keydown)
