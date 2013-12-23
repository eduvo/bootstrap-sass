define [
  "module"
  "exports"
], (module,exports) ->
  #checkbox
  $('.secondary-content').on 'change', '.cells input', (e) ->
    $target = $(e.currentTarget)
    unless $target.prop('checked')
      $target.closest('.accordion-group')
             .find('.accordion-heading')
             .find('input[type=checkbox]')
             .prop('checked',false)

      $target.closest('.payments-list')
             .find('.secondary-header')
             .find('input[type=checkbox]')
             .prop('checked',false)

  sortingBtn = $(".btn-sorting")
  sortingBtn.parent('div').on "click", ->
    sortingBtn.toggleClass('active')

  #checkbox all checked
  exports.checkAllOptionsForceChecked = (target) ->
    el = target.closest('.checkbox-wrapper')
    if target.hasClass('contact-select-group')
      el = target.closest('.accordion-group')

    if target.prop('checked') is true
      el.find('.checkbox-inner').find('input').not('.excluded').each ->
        $(this).prop('checked', true)
    else
      el.find('.checkbox-inner').find('input').not('.excluded').each ->
        $(this).prop('checked', false)

  module.exports = exports
