define ->
  KEY_UP = 38
  KEY_DOWN = 40
  KEY_ENTER = 13
  _determineKeyAction = (evt, $view, item='li')->
    keyCode = evt.keyCode
    $resultList = $view.find item
    originActiveItem = $view.find "#{item}.active"
    activeIndex = -1
    if originActiveItem.length
      activeIndex = $resultList.index originActiveItem
    switch keyCode
      when KEY_UP
        evt.preventDefault()
        evt.stopPropagation()
        activeIndex -= 1
        activeIndex = $resultList.length - 1 if activeIndex < 0

      when KEY_DOWN
        evt.preventDefault()
        evt.stopPropagation()
        activeIndex += 1
        activeIndex = 0 if activeIndex >= $resultList.length

      when KEY_ENTER
        evt.preventDefault()
        evt.stopPropagation()
        if $resultList[activeIndex]?
          link_url = $($resultList.get activeIndex).find('a').prop 'href'
          return ->
            window.location.href = link_url

    $resultList.removeClass 'active'
    ->
      $($resultList.get activeIndex).addClass 'active' if $resultList[activeIndex]?
