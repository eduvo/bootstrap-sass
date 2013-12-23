define (require) ->
  $window = $(window)
  UrlPath = require 'utils/urlpath'
  class RoutineRoute
    eventName: "RR:route"
    path: ''
    rulesPool: {}

    _prepareArgs: (rule_queue, rule_key) ->
      option = {}
      if option_candidate = @rulesPool[rule_key]?.option_candidate
        args = [rule_key, option]
        _.each option_candidate, (value, key) ->
          option[key] = rule_queue[value]
          args.push option[key]
      args

    go: (rule_queue) ->
      do @allRouteCallback if @allRouteCallback?
      rule_queue = @path.split('/')
      if (separate_url_length = rule_queue.length) > 1
        action_name = rule_queue.shift()
        rule_key = "#{action_name}_#{separate_url_length}"
        args = @_prepareArgs rule_queue, rule_key
        $window.trigger "#{@eventName}", args
      else
        $window.trigger "#{@eventName}", [@path]
      @afterCallback?.call @

    constructor: ->
      $window.on "#{@eventName}", (event, route, others...) =>
        if @rulesPool[route]?
          if @rulesPool[route].callback?
            @rulesPool[route].callback.apply(@, others)
          else
            @rulesPool[route].apply(@, others)
        else if @default?
          do @default

      @rulesPool = {} # Clear rules pool
      UrlPath.registryAction =>
        @path = UrlPath.getPath()
        do @go

    ## Setting route rules
    get: (rule, callback) ->
      rule_queue = rule.split('/')
      if (separate_url_length = rule_queue.length) > 1
        action_name = rule_queue.shift()
        option_candidate = {}
        _.each rule_queue, (rule, index) ->
          if (plain_rule = /\:\w+/.exec(rule)[0]?.replace(':','')) isnt ''
            option_candidate[plain_rule] = index

        @rulesPool["#{action_name}_#{separate_url_length}"] =
          callback: callback
          option_candidate: option_candidate
      else
        @rulesPool[rule] = callback
      this

    done: ->
      @path = UrlPath.getPath()
      do @go if @path isnt ''
      this

    after: (@afterCallback) ->
      this

    all: (callback) ->
      @allRouteCallback = callback
      this

    trigger: (rule) ->
      $window.trigger "#{@eventName}", [rule]

    route: (@rulesPool) ->

    default: (@default) ->
      this

  new RoutineRoute
