define ['accounting.min'], (accounting) ->

  format: (num, useShort = false) ->
    num = parseInt(num, 10)
    if useShort
      if num > 999999
        accounting.formatMoney(num / 1000000, precision: 2) + 'M'
      else if num > 999
        accounting.formatMoney(num / 1000, precision: 1) + 'K'
      else
        accounting.formatMoney(num, precision: 0)
    else
      accounting.formatMoney(num, precision: 0)
