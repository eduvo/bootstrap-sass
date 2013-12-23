###
Usage:

1. Requires this module.
###

define ->
  $ ()->
    $('button[value="delete"]').click ->
      return false if $('input:checkbox[name="ids[]"]:checked').length == 0
