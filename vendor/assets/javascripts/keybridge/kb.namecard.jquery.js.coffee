do ->
  $.fn.namecard = (callback=null) ->
    @.each ->
      $.this = $(@)
      $.this.parent('div').css('position','relative')
      $.this.parent('div').on 'mouseenter', (e)->
        el = $(e.currentTarget)
        el.addClass('nc-hover')
      $.this.parent('div').on 'mouseleave', (e)->
        el = $(e.currentTarget)
        el.removeClass('nc-hover')
      if callback
        callback()
