# Search anything
define (require) ->
  _determineKeyAction = require 'keybridge/search_navigation'

  $parent = $('#title-bar')
  $mainContainer = $parent.find('#search-result')
  $searchInput = $parent.find 'input#main-search'
  $resultsContainer = $mainContainer.find '.result-render-area'
  searchUrl = $searchInput.data 'url'
  _debounceTime = 500
  #template
  tmpl = $parent.find('#search-anything-tmpl').text()

  _bindUpDown = ->
    $(document).on 'keydown.search_up_down_nav', (evt)->
      do callback = _determineKeyAction evt, $mainContainer

  _unbindUpDown = ->
    $(document).off 'keydown.search_up_down_nav'

  _renderOne = ( row, keyword ) ->
    pattern = new RegExp("(#{keyword})", 'ig')
    row.name = row.name.replace pattern, (match) ->
      "<b>#{match}</b>"
    row.is_organization = row._type is "organization"
    $resultsContainer.append Mustache.render(tmpl, row)

  _renderAll = ( rows, keyword ) ->
    do _unbindUpDown
    do _bindUpDown
    $resultsContainer.html "" unless $resultsContainer.find("li").length
    $.when(_.each rows, (row, index) ->
      _renderOne row, keyword
    ).then ->
      $resultsContainer.html "No results." unless $resultsContainer.find("li").length

  _search = (e) ->
    $el = $(e.currentTarget)
    value = $.trim($el.val())
    data = s: value
    shown = ($mainContainer.css('display') is 'block')
    if value.length < 3
      $mainContainer.hide() if shown
      do _unbindUpDown
      return
    $mainContainer.show() unless shown
    $resultsContainer.empty()
    all_length = 0
    $.get searchUrl, data, (resp) ->
      all_length += resp.result.people.count + resp.result.organizations.count
      _renderAll resp.result.people.results, data.s
      _renderAll resp.result.organizations.results, data.s
      if all_length > 0
        x = $.Event("keydown.search_up_down_nav")
        x.keyCode = 40
        $parent.trigger x


  $(document).on 'click', (e)->
    if $(e.target)[0] is $searchInput[0]
      return false

    unless $(e.target).closest('#search-result').length
      do _unbindUpDown
      $mainContainer.hide()
      $searchInput.val('')

  _debounceSearch = _.debounce(_search, _debounceTime)
  $searchInput.on 'input', _debounceSearch
