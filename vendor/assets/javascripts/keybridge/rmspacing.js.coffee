define ->
#remove spacing between inline-block elments
  $.fn.removeInlineBlockSpacing = (options) ->
    $(this).contents().filter(->
      @nodeType is 3
    ).remove()
