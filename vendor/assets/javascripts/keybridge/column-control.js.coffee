define (require)->
  #control right sidebar width toggle hiden
  $('#column-control').on 'click', ->
    $('.grid-stage').toggleClass('active')
    $(this).toggleClass('expand')

  $('#column-control').on 'force.active', ->
    $('.grid-stage').addClass 'active'
    $('#column-control').addClass 'expand'

  $('#column-control').on 'force.close', ->
    $('.grid-stage').removeClass 'active'
    $('#column-control').removeClass 'expand'
