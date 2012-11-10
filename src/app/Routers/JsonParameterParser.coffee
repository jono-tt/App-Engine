#<< AppEngine/Objects/Object
class JsonParameterParser extends AppEngine.Objects.Object
  constructor: ->
    super()
    @regex = new RegExp("([^/]*)/?([^/]*)?/?", '')

  parseParameters: (url) ->
    pageParams = [] 

    if !_.isEmpty(url)
      matches = @regex.getMatches(url)
      if matches.length > 0
        for match in matches
          try
            pageParams.push({
              pageName: match[1],
              params: getParams.call @, match[2]
            })
          catch e
            @logger.error "Routing: #{match[1]}: Error parsing params"
            throw new AppEngine.Helpers.Error "Routing: #{match[1]}: Error parsing params", e
      else
        #this contains only the page name
        pageParams.push({
          pageName: url
        })

    return pageParams

  getParams = (paramString) ->
    if !_.isEmpty(paramString)
      try
        decodedUrl = urlDecode.call(@, paramString)
        decodedUrl = decodedUrl.replace("'", "\"", 'g')

        return $j.parseJSON decodedUrl
      catch e
        throw new AppEngine.Helpers.Error "Error parsing params '#{urlDecode.call(@, paramString)}' to JSON", e

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

