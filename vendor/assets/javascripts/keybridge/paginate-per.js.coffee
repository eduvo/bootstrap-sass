###
Usage:

 1. Requires this module.
 2. Add `data-action="paginate-per"` attribute to the specific select tag.

XXX Need replace this file use AJAX update

###

define ->
  parseQueryString = ->
    nvpair = {}
    qs = window.location.search.replace('?', '')
    return nvpair if qs.length == 0
    pairs = qs.split('&')
    $.each(pairs, (i, v) ->
      pair = v.split('=')
      nvpair[pair[0]] = decodeURIComponent(pair[1])
    )
    nvpair

  $(document).on 'change', 'select[data-action="paginate-per"]', (evt)->
    no
    #nvpair = parseQueryString()
    #nvpair["per"] = $(this).val()
    #document.location.href = "#{document.location.pathname}?#{$.param(nvpair)}"
