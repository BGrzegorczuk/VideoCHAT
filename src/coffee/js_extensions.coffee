define [], () ->
  # Compare two arrays. Js doesn't have a native arrays comparator
  Array::compare = (array) ->
    # if the other array is a falsy value, return
    return false  unless array

    # compare lengths - can save a lot of time
    return false  unless @length is array.length
    i = 0

    while i < @length
      # Check if we have nested arrays
      if this[i] instanceof Array and array[i] instanceof Array

        # recurse into the nested arrays
        return false  unless this[i].compare(array[i])

      # Warning - two different object instances will never be equal: {x:20} != {x:20}
      else return false  unless this[i] is array[i]
      i++
    true

  ## Array Remove - By John Resig (MIT Licensed)
  Array::remove = (from, to) ->
    rest = @slice((to or from) + 1 or @length)
    @length = (if from < 0 then @length + from else from)
    @push.apply this, rest
