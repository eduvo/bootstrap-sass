# RemoveImage Utility
#
# @example
#   <div class=".frame">
#   <img src="foo.png">
#   </div>
#   <button data-default-image="/assets/sample/default-logo.png" data-remove-input="remove_logo" data-remove-photo="true" data-target=".frame img" name="button" type="submit">Remove Photo</button>
#
define (require) ->
  $('button[data-remove-photo]').on 'click', (e)->
    e.preventDefault()
    $this = $(e.currentTarget)
    selector = $this.data 'target'
    default_image = $this.data 'default-image'
    input_name = $this.data 'remove-input'
    $("input[name$='[#{input_name}]']").val '1'
    $(selector).attr 'src', default_image
    no
