# ImagePreview Utility
#
# @example
#   <img src="foo.png">
#   <input type="file" data-image-preveiw="true" data-target=".frame img">
#
define (require) ->
  # Constants
  MODULE_NAME = 'image-preview'
  SELECTOR    = '[data-image-preview]'

  # An image preview utility for HTML5 file field.
  #
  # @example
  #   new ImagePreview('.attachment-field', '.frame img');
  #
  # @param [String|HTMLElement|Object] File input field
  # @param [String|HTMLElement|Object] Image tag
  #
  class ImagePreview

    constructor: (@input, @image) ->
      @input = $(@input)
      @image = $(@image)
      @input.data('image-preview', @)
      @input.data('target', @image)
      @input.on('change', @handleChange)

    # Shows the local image while user changes file field.
    handleChange: (e) ->
      # Stops event bubbling if not lazy bind.
      e.stopPropagation() if (e.target.tagName != 'html')
      # Makes sure HTML5 FileReader does exist.
      return unless window.FileReader?
      # Creates instance only once.
      reader = new FileReader() unless reader?
      $el = $(e.target)
      file = e.target.files[0]
      selector = $el.data('target')
      input_name = $el.data('remove-input')
      reader.readAsDataURL(file)
      reader.onload = (e) ->
        $(selector).attr('src', e.target.result)
        $("input[name$='[#{input_name}]']").val("0")

  # An image preview utility for HTML5 file field.
  #
  # @example
  #   $('.attachment-field').imagePreview('.frame img');
  #
  # @param [String|HTMLElement|Object] File input field
  # @param [String|HTMLElement|Object] Image tag
  #
  $.fn.imagePreview = (option) ->
    @.each ->
      $that = $(@)
      data = $that.data('image-preview')
      if (!data)
        data = new ImagePreview(@, option.target)
        $that.data('image-preview', data)

  # Lazy bind event without creating any instance.
  $(document).on("change.#{MODULE_NAME}", SELECTOR, ImagePreview::handleChange)

  return ImagePreview
