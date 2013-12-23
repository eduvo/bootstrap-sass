define (require) ->
  require 'stripe-v2'
  class StripCreditCard
    constructor: ( @dom ) ->
      @number = @dom.find('[data-stripe=number]').val()
      @cvv = @dom.find('[data-stripe=cvv]').val()
      @exp_month = @dom.find('[data-stripe=exp-month]').val()
      @exp_year = @dom.find('[data-stripe=exp-year]').val()
    validate: ->
      Stripe.card.createToken({
        number: @number,
        cvc: @cvv , # key is 'cvc' in stripe, but we use cvv in view
        exp_month: @exp_month,
        exp_year: @exp_year
      }, StripeValidator.stripeResponseHandler )

  StripeValidator =
    init: ( @form, @callback = {} ) ->
      Stripe.setPublishableKey @form.data('stripe-token')
      @form.find('[type=submit]').on 'click', @_eventSubmit
      form = @form
      @form.find('[data-stripe=credit-card]').each ->
        $fieldset = $(@)
        number = $fieldset.find('[data-stripe=number]').val()
        $fieldset.attr('data-stripe-status', 'success') # Default should be always 'success'.
        $fieldset.find('[data-stripe]').on 'input change', (e) ->
          status = 'success'
          $fieldset.find('[data-stripe]').each ->
            $target = $(@)
            value = $.trim($target.val())
            switch $target.attr('data-stripe')
              when 'number'
                if number != value
                  status = 'pending'
                  return false
              else
                if $.trim($(@).val()) != ''
                  status = 'pending'
                  return false
          $fieldset.attr('data-stripe-status', status) # Default should be always 'success'.
    _eventSubmit: (event) ->
      if StripeValidator.isUseCreditCard()
        StripeValidator.form.find('button').prop('disabled', true )
        StripeValidator.perform()
        false
      else
        true
    isUseCreditCard: ->
      @form.find('input[value=credit_card]').prop('checked')
    perform: ->
      v = @isAllValid()
      if current = @getNextCreditCard()
        @currentCreditCard = new StripCreditCard( current )
        @currentCreditCard.validate()
      else if @isAllValid()
        @submitForm()
      else
        @form.find('button').prop('disabled', false)
        false
    getNextCreditCard: ->
      cc = @form.find('[data-stripe=credit-card][data-stripe-status=pending]')
      if cc.length > 0 then cc.first() else false
    validate: ( cc ) ->
      StripeValidator.currentForm.find('button').prop('disabled', true)
      Stripe.card.createToken({
        number: cc.number,
        cvc: cc.cvv , # key is 'cvc' in stripe, but we use cvv in view
        exp_month: cc.exp_month,
        exp_year: cc.exp_year
      }, @stripeResponseHandler)
    isAllValid: ->
      @form.find('[data-stripe=credit-card]').size() == @form.find('[data-stripe=credit-card][data-stripe-status=success]').size()
    submitForm: ->
      if @callback?
        @callback()
      else
        @form.get(0).submit()

    stripeResponseHandler: ( status, response ) ->
      cc = StripeValidator.currentCreditCard
      if response.error
        cc.dom.attr('data-stripe-status','error')
        StripeValidator.errorMessage( response.error )
      else
        cc.dom.attr('data-stripe-status','success')
        cc.dom.find('.payment-errors').empty()
        token = response.id
        cc.dom.find('[data-stripe=token]').val(token)

      StripeValidator.perform()
    errorMessage: (error) ->
      if error.param == 'cvc'
        error.param = 'cvv'
      $('[data-stripe='+error.param+']').closest('.control-group')
      error.param ||= 'number'
      group = $('[data-stripe='+error.param.replace('_','-')+']').closest('.control-group')
      group.addClass('error').find('.help-inline').remove()
      span = $('<span class="help-inline"></span>')
      span.text( error.message )
      group.append span


  # Creates Dropform Plugin
  $.fn.stripe = (option) ->
    @.each ->
      StripeValidator.init($(@), option)
  $.fn.stripe.Constructor = StripeValidator
  StripeValidator
