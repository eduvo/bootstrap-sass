# Default .grid-stage min-height which sets in CSS.
# Shouldn't update it when target height is less than this value.
MIN_HEIGHT = $('.grid-main').outerHeight()
exports = {}
exports.dashboardMinHeight = (selector = '.grid-stage') ->
  return no if window.noResetStageHeight
  $target = $(selector)
  $target.css('min-height', MIN_HEIGHT)
  targetHeight = MIN_HEIGHT
  # Loops to find the highest block in layout.
  $('.grid-b >.grid-u, #bd >.grid-b').each ->
    height = $(this).outerHeight()
    return if height < MIN_HEIGHT
    if height > targetHeight
      targetHeight = height
      $target.css('min-height', targetHeight)
    return

$(window).on 'window:calc_grid_height', exports.dashboardMinHeight
do exports.dashboardMinHeight
window.calcGridHeight = exports
