#FUNCTION OVERRIDES
Function.prototype.getName = ->
    m = @toString().match(/^function\s(\w+)/)
    if m then m[1] else "anonymous"


Function.prototype.createDelegate = (c, b, a) ->
  d = this
  return ->
    f = b || arguments;

    if a == true
      f = Array.prototype.slice.call arguments, 0
      f = f.concat b
    else
      if typeof a == "number"
        f = Array.prototype.slice.call arguments, 0
        e = [a, 0].concat b
        Array.prototype.splice.apply f, e

    return d.apply (c or this), f

Object.prototype.mixin = (Klass) ->
  # assign class properties
  for key, value of Klass
    @[key] = value

  for key, value of Klass.prototype
    # assign instance properties
    @::[key] = value
  @
