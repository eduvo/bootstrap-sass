# FancySelect
# custom select and option style
(($) ->
  $.fn.fancySelect = (options) ->
    settings =
      mainClass: "fancySelectMain"
      toggleClass: "fancySelectToggle"
      itemListClass: "fancySelectBody"
      itemClass: "fancySelectOptionItem"

    settings = $.extend(settings,options)

    # Init plugin.
    @.each ->
      $this = $(@)
      if $this.data 'fancy-select'
        return
      $this.data 'fancy-select', yes
      if !!$this.attr('class')
        originClass = $this.attr('class')

      classList = settings.mainClass.split(" ")
      classList.push originClass
      classes = classList.join(" ")

      # Hidden origin select
      $this.hide()
      options = $this.find('option')

      mainDiv = $('<div/>')
        .addClass(classes)
        .data('fancy-select', yes)
      toggleEle = $('<a/>').addClass settings.toggleClass
      toggleBtn = $('<div/>').addClass 'btn'
      toggleHeader = options.first().html()

      if $this.find('option[selected]').length
        toggleHeader = $this.find('option[selected]').html()
      toggleHeader = $('<span/>').html(toggleHeader)

      optionBody = $('<ul/>').addClass settings.itemListClass
      options.each (index,ele) ->
        listEle = $('<li/>').addClass(settings.itemClass)
                            .attr('data-value', $(ele).attr('value'))
                            .html(ele.text)

        if ele.text is toggleHeader.text()
          listEle.addClass 'active'
        optionBody.append listEle

      # concat new style element
      toggleEle.append toggleHeader
      toggleBtn.append $('<i class="icon-chevron-down"/>')
      toggleEle.append toggleBtn

      # append all element
      mainDiv.append toggleEle
      mainDiv.append optionBody

      # event binding
      mainDiv.on 'click.fancyselect', ".#{settings.toggleClass}", (e)->
        do optionBody.toggle
        e.preventDefault()

      optionBody.on 'click.fancyselect', "li", (e)->
        el = $(e.target)
        el.siblings('li').removeClass 'active'
        el.addClass 'active'
        eleIndex = el.index()
        $this.val(el.data 'value')
        toggleHeader.html(el.text())
        optionBody.hide()
        $this.trigger 'change'

      $this.on 'change.fancyselect', (e) ->
        $el = $(e.target)
        value = $el.val()
        text = $el.find('option:selected').text()
        toggleHeader.html(text)
        optionBody.find('li').removeClass('active')
        optionBody.find("li[data-value='#{value}']").addClass 'active'


      $this.before mainDiv

      $(document).on 'click.fancyselect', (e)->
        if $(e.target).closest(mainDiv).length
          return no
        do optionBody.hide

      $(@.form).on 'reset.fancyselect', (e) =>
        $el = $(@)
        # Form reset doesn't immediately update select value.
        setTimeout =>
          value = $el.val()
          text = $el.find('option:selected').text()
          toggleHeader.html(text)
          optionBody.find('li').removeClass('active')
          optionBody.find("li[data-value='#{value}']").addClass 'active'
        , 100

      #TODO: Setting fix width when list item appended.
      $this
)(jQuery)
