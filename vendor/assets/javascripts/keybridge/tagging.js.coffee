define (require) ->
  require 'select2'
  class Tagging
    constructor: (@element, @url, @default)->
      $element = $(@element)
      $element.select2 {
        tags: []
        tokenSeparators: [","]
        formatSearching: -> "Searching Tags..."
        createSearchChoice: (term, data) ->
          return {id: term, text: term} if $(data).filter(-> @text.localeCompare(term) is 0).length is 0
        ajax:
          url: "/search_tag"
          dataType: 'json'
          data: (term, page) ->
            {
              s: term
              limit: 10
            }
          results: (data, page) ->
            result = _.first data.result, 10 # Pick first 10 row
            result = _.map result, (item) ->
              item.id = item.text
              item
            return {results: result}
      }
      @default = @default.map (item) ->
        result = {id: item, text: item}
        result
      $element.select2("data", @default)

    syncTags: (params, callback)->
      console.log 'Params: ', params
      $.post @url, params, (resp) ->
        callback.call @, resp

  $.fn.tagging = (options) ->
    defaultOption =
      callback: null
      url: null
      default: []

    options = $.extend {}, defaultOption, options
    @.each ->
      $this = $(@)
      tagging = new Tagging(@, options.url, options.default)
      if options.callback?
        options.callback.call tagging, tagging
