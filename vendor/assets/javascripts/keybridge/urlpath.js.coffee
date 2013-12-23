define ->
  class UrlPath
    prefix = '#!/'
    chain = {}
    clearChain = ->
      chain = _.each chain, (value, key) ->
        unless value then delete chain[key]

    updateHashbang = ->
      clearChain()
      path = _.reduce(chain, (path, value, key) ->
        if value? then path + "&#{key}=#{value}"
      ,"")
      path = prefix + path.slice(1)
      window.location.hash = path

    @refineParam = (url_param = null) ->
      result = {}
      params = window.location.hash || window.location.search
      plainText = if url_param? then url_param else params
      qs = plainText.replace('?', '')
      qs = qs.replace(prefix, '')
      if qs.length
        pairs = qs.split('&')
        $.each(pairs, (i, v) ->
          pair = v.split '='
          [key, val] = [pair[0], pair[1]]
          result[key] = decodeURIComponent(val) if key? and val?
        )
      result

    @update: (name, value) ->
      chain[name] = value

    @remove: (name) ->
      delete chain[name]

    @getPath: ->
      plainText = window.location.search || window.location.hash
      qs = plainText.replace('?', '')
      qs = qs.replace(prefix, '')
      qs = qs.replace('#/', '')

    @route: ->
      do updateHashbang

    @registryAction: (callback) ->
      $(window).off 'popstate'
      $(window).on 'popstate', callback
      $(@).off 'forceupdate'
      $(@).on 'forceupdate', callback
