class JsonParameterParser

  parseParameters: (params) ->

    obj = null;

    #callback of this function to control display
    if !_.isEmpty(params)
      try
        obj = $j.parseJSON urlDecode(params)
      catch e
        #do nothing, just cannot parse JSON
        console.debug "Cannot parse '", urlDecode(params), "' to JSON"

    return obj

  urlDecode = (str) ->
    return decodeURIComponent((str + '').replace(/\+/g, '%20'))

  getDeviceRoutingObjects: ->
    routingData = $j("#device-routing")

    if routingData && routingData.html() != ""
      deviceRouting = $j.parseJSON routingData.html()

      if deviceRouting
        #todo: create router
        routingObjects = []

        return routingObjects
      else
        #parsing failed
        console.log "Error parsing routingData", routingData

    return null