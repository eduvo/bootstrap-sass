define (require) ->
  require 'bootstrap-datepicker'
  require 'utils/fancyselect.jquery'
  class EmbedTimePicker
    SET_WITHOUT_TIME = 'DD MMM YYYY [00:00:00]'
    SET_WITH_TIME    = 'DD MMM YYYY hh:mm a'
    FORMAT_DB        = 'YYYY-MM-DD' # 1970-1-1
    FORMAT_VIEW      = 'MMM DD, YYYY' # Dec 12, 2013
    options:
      autoclose: false
    constructor: ( options ) ->
      @options = $.extend true, {}, @options, options
      @window = $ window
      @root   = @options.input
      @select = @options.select
      @option = @options.option
      @val    = @root.attr('value') # Can't use @root.val()

      # Generate
      @picker @options
      @picker().picker.addClass 'embed-timepicker'

      # Add timepicker
      $timePicker = $ '
        <div class="timepicker">
          <select name="hour">
          </select>
          <select name="minute">
          </select>
          <select name="ampm">
            <option value="am">am</option>
            <option value="pm">pm</option>
          </select>
        </div>
      '
      @hour        = $timePicker.find '[name="hour"]'
      @minute      = $timePicker.find '[name="minute"]'
      @ampm        = $timePicker.find '[name="ampm"]'
      @timePickers = $timePicker.find 'select'
      @hour.append "<option value=12>12</option>"
      for i in [1...12] by 1
        @hour.append "<option value=#{i}>#{i}</option>"
      for i in [0...60] by 5
        i = if i < 10 then "0#{i}" else i
        @minute.append "<option value=#{i}>#{i}</option>"

      @timePickers.fancySelect()
      @picker().picker.find('.datepicker-days').append $timePicker

      # Reset picker date
      @resetPicker @readDate()

      # Bind
      @window.on 'keydown', @keydown
      @timePickers.on 'change', @changeTime
      @root.on 'changeDate', @changeDate
      @picker().picker.find('.fancySelectToggle span').on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()
    keydown: (e) =>
      @destroy() if e.which is 27
    changeTime: =>
      @set @readDate()
    changeDate: (e) =>
      @set e.date
    set: (date) ->
      hour      = @hour.val()
      minute    = @minute.val()
      ampm      = @ampm.val()
      theMoment = moment( date )

      if hour is "12" and minute is "00" and ampm is "am"
        viewTime = theMoment.format( FORMAT_VIEW )
        dbTime   = theMoment.format( FORMAT_DB )
      else
        viewTime = theMoment.format("#{FORMAT_VIEW} [at] [#{hour}]:[#{minute}] [#{ampm}]")
        dbTime   = theMoment.format("#{FORMAT_DB} [#{hour}]:[#{minute}] [#{ampm}]")

      @val = dbTime
      @root.attr 'value', dbTime # Can't use @root.val dbTime
      @option.text( viewTime ).val( dbTime )
      @select.select2 'val', dbTime
    resetPicker: ( date ) ->
      hour   = date.getHours() % 12 || 12
      minute = date.getMinutes() || 0
      ampm   = if date.getHours() >= 12 then 'pm' else 'am'
      minute = "0#{minute}" if minute < 10

      @hour.val( hour ).change()
      @minute.val( minute ).change()
      @ampm.val( ampm ).change()
      @picker 'update', moment( date ).format( FORMAT_VIEW )
    readDate: ->
      formats =
        'YYYY-MM-DD'        : SET_WITHOUT_TIME
        'MM/DD/YYYY'        : SET_WITHOUT_TIME
        'YYYY-MM-DD hh:mm'  : SET_WITH_TIME
        'YYYY-MM-DD hh:mm a': SET_WITH_TIME

      if not @val
        dateString = moment( new Date() ).format SET_WITHOUT_TIME
      else
        for origin, res  of formats
          if @isMatch origin
            dateString = moment( @val, origin ).format( res )
            break
      date = new Date dateString
      date
    isMatch: ( format ) ->
      return moment( @val, format, true ).isValid() if typeof format is 'string'
      for f in format
        return true if moment( @val, format, true ).isValid()
      no
    picker: ( option, val ) ->
      return @root.data('datepicker') if not option
      @root.datepicker option, val
    show: ->
      @picker 'show'
    destroy: ->
      bp = @picker()
      return if not bp
      bp.picker.off('click').remove()
      if bp.isInput
        bp.element.off('focus keyup')
      else
        if bp.component
          bp.component.off 'click'
        else
          bp.element.off 'click'
      bp.element.removeData 'datepicker'

      @window.unbind 'keydown', @keydown
      @root.unbind('changeDate').removeData 'embedTimePicker'