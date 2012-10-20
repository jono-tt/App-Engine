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

RegExp.prototype.getMatches = (text) ->
    index = -1
    matches = []
    while (text.length > 0 and (match = @exec(text)) != null)
      index = match.index + match[0].length

      text = text.substring(index)
      matches.push(match)

    return matches

#TODO: decide if we are going to introduce mixins
# Object.prototype.mixin = (Klass) ->
#   # assign class properties
#   for key, value of Klass
#     @[key] = value

#   for key, value of Klass.prototype
#     # assign instance properties
#     @::[key] = value
#   @
