define [], () ->

  getCurrTime = ->
    now = new Date()
    h = now.getHours()
    h = if h > 9 then h else '0'+h
    m = now.getMinutes()
    m = if m > 9 then m else '0'+m
    s = now.getSeconds()
    s = if s > 9 then s else '0'+s
    return "#{h}:#{m}:#{s}"

  utils =
    getCurrTime: getCurrTime

  return utils