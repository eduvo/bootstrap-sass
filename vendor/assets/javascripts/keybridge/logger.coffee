define ->
  do ->
    _console = window.console || undefined
    _replaceStatus = no
    _logStatus = yes
    @log = (e) ->
      _console?.log.apply _console, arguments if _logStatus
    @table = (e) ->
      _console?.table.call _console, arguments if _logStatus

    @warn = ->
      no

    @info = ->
      no

    @error = ->
      no

    window.console = @ if _replaceStatus or !_logStatus
    window.console
