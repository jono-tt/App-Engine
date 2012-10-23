#<< AppEngine/Objects/Object
class JsonParameterParser extends AppEngine.Objects.Object
  constructor: ->
    @regex = new RegExp("([^/]*)/?([^/]*)?/?", '')

  parseParameters: (url) ->
    pageParams = [] 

    if !_.isEmpty(url)
      matches = @regex.getMatches(url)
      if matches.length > 0
        for match in matches
          pageParams.push({
            pageName: match[1],
            params: getParams match[2]
          })
      else
        #this contains only the page name
        pageParams.push({
          pageName: url
        })

    return pageParams

  getParams = (paramString) ->

    if !_.isEmpty(paramString)
      try
        return $j.parseJSON urlDecode(paramString)
      catch e
        #do nothing, just cannot parse JSON
        @logger.debug "Cannot parse '", urlDecode(paramString), "' to JSON"

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
        @logger.log "Error parsing routingData", routingData

