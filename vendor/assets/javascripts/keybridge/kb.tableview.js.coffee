###
 Keybridge Table view control
   columns_statements: This file define the field candidate,
 field label and sort arguments.
###
define (require)->
  require 'jquery.currency'

  UrlPath = require 'keybridge/urlpath'
  Pagination = require 'keybridge/kb.pagination'
  ColumnStatements = require 'contact/shared/columns_statements'
  TableViewTemplate = require 'contact/shared/tableview.tpl'

  COL_COOKIE_KEY = 'list_columns:'
  ORDER_KEY = 'columns_order:'

  $cols_window = $('.define-cols-window')
  cols_target = $cols_window.data 'target'

  COL_ORDER_BY_HASH = ColumnStatements[cols_target].columns_order_by
  COLUMN_LABEL = ColumnStatements[cols_target].column_label
  TITLE_COL = TableViewTemplate.title_col
  TITLE_ROW = TableViewTemplate.title_row
  COL = TableViewTemplate.col
  COL_NAMECARD = TableViewTemplate.col_namecard
  COL_ORG_GROUP = TableViewTemplate.col_org_group
  ROW = TableViewTemplate.row
  DATE_FORMAT = "MMM D, YYYY"
  CR = "<br/>"
  PPL = 'people'
  ORG = 'organization'

  class TableView
    _duration = 200
    _get = _.debounce $.get, _duration
    _pagination = new Pagination $('.pages-selector')
    _getString = (str) ->
      return '' unless str
      str
    _isNowrap = (key) ->
      key in [
        'country_name'
      ]
    _prepareColumn = (column_key, column_object, data) ->
      return '' unless column_object
      if $.type(column_object) is 'object'
        switch column_key
          when 'primary_address' then do ->
            address = "<p class='address'>"
            address += "#{_getString column_object.address} #{CR}" if column_object.address
            address += "#{_getString column_object.address_ii} #{CR}" if column_object.address_ii
            address += "#{_getString column_object.city}, " if column_object.city
            address += "#{_getString column_object.state} " if column_object.state
            address += "#{_getString column_object.postal_code} #{CR}" if column_object.postal_code
            address += "#{_getString column_object.country_name} #{CR}" if column_object.country_name
            address += "</p>"
          else do ->
            ''
      else if $.isArray(column_object)
        return '' unless column_object.length
        switch column_key
          when 'annual_upsell_value_items', 'enabled_subscriptions', 'subscriptions'
            Mustache.render TableViewTemplate.annual_upsell, column_object

          when 'invoices'
            Mustache.render TableViewTemplate.invoices_dl, column_object

          when 'invoices.total'
            Mustache.render TableViewTemplate.invoices_amount, column_object

          when 'invoices.status'
            Mustache.render TableViewTemplate.invoices_status, column_object

          when 'invoices.due_on'
            Mustache.render TableViewTemplate.invoices_due_on, _.map column_object, (object) ->
              object.due_on = moment(object.due_on).format DATE_FORMAT
              object

          when 'invoices.issued_on'
            Mustache.render TableViewTemplate.invoices_issued_on, _.map column_object, (object) ->
              object.issued_on = moment(object.issued_on).format DATE_FORMAT
              object
      else
        switch column_key
          when 'expected_price'
            "<span class='currency'>#{column_object}</span>"
          when 'name'
            "<span class='org-name'>#{column_object}</span>"
          when 'organization.name'
            "<a href='/organization/#{data.organization.id}'>#{column_object}</a>"
          when 'billing_renewal_month'
            moment()
              .months(column_object - 1)
              .format('MMMM')
          when 'subscription_status_name'
            "<a href='#' class='status-filter' data-param='type_ids' data-id='#{data.subscription_status_id}'>#{ column_object }"
          when 'country_name'
            Mustache.render TableViewTemplate.country_name,
              country_alpha2: data.country_alpha2
              country_name: column_object
              country_icon: data.country_icon
          else
            column_object

    # Prepare key value b/c the key value might have a point symbol that repre-
    # sents to use child object's attribute.
    _prepareKey = (key) ->
      key_list = key.split '.'
      return key_list

    is_user_define_col: no
    col_list: []
    params_white_list:[
      'target'
      'order'
      'type_ids'
      'region_ids'
      'tag_ids'
      'product_ids'
      'page'
      'per'
    ]
    reset_title: yes

    constructor: (@url, @$container, @$title_container, @template, @is_user_define_col) ->
      if @is_user_define_col
        throw Error("Need $title_container") unless @$title_container
        throw Error("Need col_list in cookie") unless @col_list

      UrlPath.registryAction updateAction = =>
        hash = window.location.hash
        params = UrlPath.refineParam hash
        if $.isEmptyObject(params) and gon?.cache_contacts_first_p?
          @renderAll gon.cache_contacts_first_p
          $('.namecard').namecard()
          _pagination?.updatePagination params
        else
          @sendRequest params, ->
            $('.namecard').namecard()
          _pagination?.updatePagination params

      updateAction()

      $container.on 'content:update', (e) =>
        @reset_title = yes
        if @data.length
          @$container
            .closest('div')
            .addClass 'loading'
          @renderAll @data
          $('.adjustable .cells').resizable handles: 'e'
          $('.namecard').namecard()
          @$container
            .closest('div').removeClass 'loading'
        else
          $(UrlPath).trigger 'forceupdate'

    renderAll: (list) ->
      # Cache the data
      @data = list
      @col_list = $.cookie(COL_COOKIE_KEY + cols_target).split ','
      @$container.empty()
      @$container.append(@renderOne data, seq) for data, seq in list
      if @is_user_define_col and @col_list.length and @reset_title
        @$title_container.html @renderDefineTitle(@col_list, $('#accordion-company-contacts-title th'))
        @$title_container.trigger 'refresh_sorting_symbol'
        @reset_title = no

      $('.currency').currency decimals: 0
      $('#column-control').trigger 'force.active' if @col_list.length > 4
      yes

    renderOne: (data, seq) ->
      if @is_user_define_col and @col_list.length
        renderedContent = @renderDefineCols @col_list, data, seq
      else
        renderedContent = Mustache.render(@template, data)
      return renderedContent

    renderDefineTitle: (cols, $orgin_title) ->
      row_content = ''
      t_class = 'adjustable'

      _.each cols, (key) ->
        row_content += Mustache.render TITLE_COL,
          value: COLUMN_LABEL[key]
          id: COL_ORDER_BY_HASH[key]
          key: key
          t_class: t_class
          c_class: unless COL_ORDER_BY_HASH[key] is '' then 'sortable' else 'unsortable'
      Mustache.render TITLE_ROW, cols: row_content

    renderDefineCols: (cols, data, seq) ->
      return '' unless cols.length and data
      row_content = []
      col_raw = ''
      _.each cols, (key, index)->
        [parent, child] = _prepareKey key
        col_val = ''

        if parent of data
          col_val = if child and child of data[parent] then data[parent][child] else data[parent]
          col_val = _prepareColumn key, col_val, data

        if index is 0 and cols_target is PPL
          col_raw = Mustache.render COL_NAMECARD, value: col_val, data: data
        else if index is 0 and cols_target is ORG
          col_raw = Mustache.render COL_ORG_GROUP, value: col_val, data: data
        else
          col_raw = Mustache.render COL, value: col_val
          col_raw = Mustache.render COL, value: col_val, special_class: 'nowrap' if _isNowrap(key)

        row_content.push col_raw
      return Mustache.render ROW, cols: row_content.join(''), id: data.id

    sendRequest: (params, callback) ->
      @$container
        .closest('div')
        .addClass 'loading'

      _get @url, params, (result) =>
        @renderAll result
        $('.adjustable .cells').resizable handles: 'e'
        callback?()
        @$container
          .closest('div').removeClass 'loading'

        @$container.trigger 'refresh_filter', [params]

    filterParams: (params) ->
      params = _.pick params, @params_white_list

    changeState: (params, callback) ->
      params = @filterParams params
      unless params['page']? then UrlPath.remove('page')
      _.each params, (value, key) ->
        UrlPath.update key, value
      do UrlPath.route

