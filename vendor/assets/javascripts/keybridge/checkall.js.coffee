##
#  Usage
#  -------
#  JavaScript
#
#    require(['keybridge/checkall'], function () {
#       // You don't have to invoke anything, just include the `keybridge/checkall` module.
#    })
#
#  HTML
#
#    <input type="checkbox"
#           data-toggle="checkall"
#           data-target="ul li input[type=checkbox]">
#
##
define (require) ->
  class Checkbox
    BULK_SIZE = 100
    LOOP_TIME = 10
    constructor: ( root )->
      @root      = root
      @is_parent = @root.data('toggle') is 'checkall'
      @children  = $(@root.data('target')) if @is_parent

      # Find parents and siblings
      @parents   = []
      @siblings  = []
      $('[data-toggle=checkall]').each (i, el) =>
        parent   = $ el
        children = $(parent.data('target')).not(parent)
        if $.inArray( @root[0], children ) > -1
          @parents.push parent
          @siblings.push children

      # No parent and no child is isolated
      @is_isolated = not @parents.length and not @is_parent

    toggle: ->
      return if @is_isolated
      checked = @root.prop 'checked'

      # Change all children status
      if @is_parent
        if (@children.length > BULK_SIZE) then @bulk(@children, checked) else @set( @children, checked )

      # Change parent status, TODO: this only change first-degree parents status
      for $parent, i in @parents
        @set( $parent, checked ) if $parent.prop('checked') or @siblings[i].length is @siblings[i].filter(':checked').length

    set: ( el, checked )->
      el.prop 'checked', checked
      el.trigger 'checkall:change'

    bulk: (el, checked) ->
      i      = 0
      offset = 0
      total  = el.length
      timer  = null
      batch = =>
        offset = Math.min( offset + BULK_SIZE, total )
        while (i < offset)
          @set( el.eq(i), checked )
          i++
        clearTimeout(timer) if timer
        timer = setTimeout(batch, LOOP_TIME) if (i < total)
      batch()

  $(document).on 'change', 'input[type=checkbox]', ->
    $checkbox = $(@)
    checkbox  = $checkbox.data 'checkbox'
    if not checkbox
      checkbox = new Checkbox $checkbox
      $checkbox.data 'checkbox', checkbox
    checkbox.toggle()

  # User may check all before JS fully loaded,
  # trigger the change event to make a delay checkall.
  $('[data-toggle=checkall]').each (i, el) ->
    $(@).trigger('change') if @.checked == true

