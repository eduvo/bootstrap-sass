define (require) ->
  require 'utils/rmspacing'

  $('.textarea-auto, .inline-blocks').removeInlineBlockSpacing()
  $.fn.switchClick = (options) ->
    main_lisShowPrivilegePanel = ($this) ->
      $this.addClass("active").attr("status", "show").siblings().removeClass("active").attr "status", "hide"
    main_lisHidePrivilegePanel = ($this) ->
      $this.addClass("active").attr "status", "show"
    OrginalOptions =
      target: "li"
      sbtn: ""

    o = jQuery.extend(OrginalOptions, options)
    swclick = $(this)
    swclick.on "click", o.target,  ->
      $this = $(@)
      window.location.hash = $this.data 'action' if $this.data('action')?
      status = "" + $(this).attr("status")
      if status is "undefined"
        $(this).attr "status", "hide"
        status = $(this).attr("status")
      if status is "hide"
        main_lisShowPrivilegePanel $(this)
      else
        main_lisHidePrivilegePanel $(this)

  $.fn.textAutoHeight = ->
    resize = ->
      textarea = $(this)
      if textarea.closest('.textarea-right').find('pre').length > 0
        textarea.closest('.textarea-right').find('pre').html(textarea.val())
      else
        styles =
          padding: textarea.css('padding')
          fontWeight: textarea.css('fontWeight')
          lineheight: textarea.css('lineheight')
          fontSize: textarea.css('fontSize')
          lettetSpacing: textarea.css('lettetSpacing')
          fontFamily: textarea.css('fontFamily')
          margin: textarea.css('margin')
        textarea.closest('.textarea-right').append('<pre><span>' + textarea.html() + '</span></pre>')
        textarea.closest('.textarea-right').find('pre').css styles
      if textarea.closest('.textarea-auto').find('textarea').length > 0
        textarea.css "height", textarea.closest('.textarea-right').find('pre').outerHeight()

    $(this).bind "keydown keyup": resize

  $.fn.textAutoWidth = ->
    if $(this).closest('.textarea-auto').find('.abs-r').length > 0
      $(this).closest('.textarea-auto').css 'paddingRight', $(this).closest('.textarea-auto').find('.abs-r').outerWidth(true) + 5
    marginLeft = 0
    totalWidth = $(this).closest('.textarea-auto').width()
    $(this).closest('.textarea-auto').find('.textarea-margin').each ->
      marginLeft += $(this).outerWidth(true)
    textareaWidth = totalWidth - marginLeft - 10
    if textareaWidth < 100
      textareaWidth = '100%'
    $(this).closest('.textarea-auto').find('.textarea-right').css 'width', textareaWidth
    if $(this).closest('.textarea-auto').find('textarea').length > 0
      $(this).textAutoHeight()

  $.fn.dropDown = ->
    $(this).delegate 'li', 'click', ->
      $(this).closest('.dropdown').find('a.dropdown-toggle').find('span').html($(this).html())
