define ->
  DELAY_HIDE_TIME = 5000

  class Notification

    constructor: (@view) ->
      # Makes this class to be a Singleton.
      if !(@view.length) || !(@view instanceof jQuery)
        console.log '[Warn] You must provide required view argument'
        return

    show: (msg, type = 'success', callback) ->
      @view.trigger('notification:show')
      @view.removeClass('alert-success alert-info alert-error').addClass("alert-#{type}")
      @view.find('p').html(msg) if msg?
      @view.fadeIn =>
        if typeof callback is 'function'
          callback.call(@)
        else
          setTimeout =>
            @hide()
          , DELAY_HIDE_TIME

    hide: (callback) ->
      @view.fadeOut =>
        callback.call(@) if typeof callback is 'function'

  new Notification $('#notification')
