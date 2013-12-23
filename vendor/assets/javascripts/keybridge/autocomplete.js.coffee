define (require) ->
  require 'jquery.ui.autocomplete'

  inputs = $('input[data-autocomplete]')
  inputs.each (i, input) -> 
    url = $(input).data('resource')
    $.getJSON url, (ret) ->
      orgs = []
      for i in ret
        orgs.push(i.name)
      $(input).autocomplete({ source : orgs })
