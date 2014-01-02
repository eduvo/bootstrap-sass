##
#  Usage
#  -------
#  JavaScript
#
#    require(['keybridge/cascade'], function () {
#       // You don't have to invoke anything, just include the `keybridge/cascade` module.
#    })
#
#  HTML
#
#    <div class="one-class-name"></div>
#    <a href="javascript:void(0)"
#       data-target="one-class-name"
#       data-toggle="cascade"
#       data-replacement="replace_string">
#       <span class="tip-text">origin_string</span>
#    </a>
#
#    * Note: data-replacemnt and .tip-text is optional
#
#  CSS
#
#    .a-class-name
#       max-height: #{the height when it is collapsed}
#
##

define (require) ->
  # Constants
  CLASS_NAME          = 'cascade'
  IN_CLASS_NAME       = 'in'
  CASCADED_CLASS_NAME = 'cascaded'
  TOGGLE_SELECTOR     = '[data-toggle=cascade]'

  class Cascade
    constructor: (toggler) ->
      # Element
      @toggler = $(toggler).data('cascade', @)
      return unless @toggler.length
      @target = $(@toggler.data('target')).addClass(CLASS_NAME)
      @tip    = @toggler.find('.tip-text')
      @tip    = @toggler if @tip.length is 0
      # Status
      @active  = @toggler.hasClass(IN_CLASS_NAME)
      # Text storage
      @origin      = @toggler.text()
      @replacement = @toggler.data('replacement')
      @replaceable = @origin? and @replacement?
      @toggler.on 'click', @toggle

    toggle: (e) =>
      e.preventDefault if (e)
      @active = !@active
      # class
      @target.toggleClass(IN_CLASS_NAME, @active)
      @toggler.toggleClass(CASCADED_CLASS_NAME, @active)
      # min-height
      @target.each ( i, t ) =>
        minHeight = if @active then t.scrollHeight else 0
        @target.css 'min-height', minHeight
      # text
      @tip.text( if @active then @replacement else @origin ) if @replaceable

  # Creates Cascade Plugin
  $.fn.cascade = (option) ->
    @.each ->
      $el = $(@)
      cascade = $el.data('cascade')
      # Initializes a new Cascade
      cascade = new Cascade($el) unless cascade
      # Executes a method.
      cascade[option].call(cascade) if (typeof option is 'string')

  $.fn.cascade.Constructor = Cascade

  old = $.fn.cascade
  $.fn.cascade.noConflict = ->
    $.fn.cascade = old
    @

  $(document).on 'click', TOGGLE_SELECTOR, ->
    $toggler = $(@)
    cascade  = $toggler.data 'cascade'
    if not cascade
      cascade = new Cascade $toggler
      $toggler.data 'cascade', cascade
      cascade.toggle()
