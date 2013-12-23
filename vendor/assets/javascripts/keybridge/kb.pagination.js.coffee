define (require) ->
  require 'utils/fancyselect.jquery'
  require 'utils/rmspacing'
  require 'utils/urlpath'
  class Pagination
    # Private
    _get = (url, params, callback) ->
      $.get url, params, callback

    # Public
    constructor: (@element, @container = null) ->
      if @element? and ($(@element).data 'url')?
        @url = $(@element).data 'url'
      else
        return false

    updatePagination: (params, url) ->
      url = url ? @url
      _get url, params, ->
        $('.fancy-select').fancySelect()
        $('.inline-blocks').removeInlineBlockSpacing()
        $('body').scrollTop(0)
