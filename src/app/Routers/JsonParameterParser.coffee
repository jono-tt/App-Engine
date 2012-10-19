class JsonParameterParser

  parseParameters: (params) ->

    retPageParams = null;
    

    #callback of this function to control display
    if !_.isEmpty(params)
      ps = params.split('/')
      obj = { pageName: ps[0] }

      if(ps.length > 1)
        try
          obj.params = $j.parseJSON urlDecode(ps[1])
        catch e
          #do nothing, just cannot parse JSON
          console.debug "Cannot parse '", urlDecode(params), "' to JSON"

      return [obj]


    return null

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
