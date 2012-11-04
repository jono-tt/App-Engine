
helpers = __t('AppEngine.Helpers')

helpers.getTemplateMarkup = (templateId) ->
  if !_.isUndefined(templateId)
    templateObj = $j "#" + templateId

    if !_.isUndefined(templateObj)
      return templateObj.text()

  return null

 
helpers.getApplicationConfig = ->
  conf = helpers.getTemplateMarkup "app-config"

  if conf
    try
      confObj = $j.parseJSON conf

      if confObj
        return confObj
      else
        throw new Error ""
    catch e
      throw new AppEngine.Helpers.Error "Unable to read the JSON config (app-config element) in the html document. Config:", 
        new AppEngine.Helpers.Error conf, e

  return {}

helpers.windowHistoryGoBack = (number) ->
  window.history.go(number * -1)


helpers.assertExists = (obj, errorMessage) ->
  if _.isUndefined(obj)
    throw new Error(errorMessage)


helpers.assertParametersExist = (paramNames, params) ->
  _.each paramNames, (name) ->
    helpers.assertExists params[name], "The constructor expects the parameter '" + name + "' to be passed in as a config parameter"


helpers.applyToObject = (paramNames, params, addToObject) ->
  _.each paramNames, (name) ->
    addToObject[name] = params[name]


helpers.getObjectByPath = (path, baseObj, def) ->
  if path
    (jsonPath baseObj, path) or def
  else
    def

helpers.asyncCallEach = (items, fn, completeCallback) ->
  count = 0
  rets = []

  complete = (item) ->
      rets.push(item)
      count++
      if count >= items.length
        completeCallback(rets)

  _.each items, (item, index) ->
    fn(item, complete, index)


helpers.createObjectByElementWrap = (elementWrap, defaultConfig, cb) ->
  config = helpers.getConfigFromElement(elementWrap.el)
  #set all the default values of this config
  _.defaults config, defaultConfig

  config.wrappedElement = elementWrap

  type = helpers.getTypeFromConfig(config)

  #create a new object of 'type'
  helpers.createObjectFromType(config, type, cb)


helpers.getConfigFromElement = (el) ->
  config = {}
  _.each el.data(), (value, name) ->
    config[name] = value

  applyScriptConfig = (config, scriptElement) ->
    if scriptElement and scriptElement.length > 0 and scriptElement[0].nodeName == "SCRIPT" and scriptElement.attr("name") == "config"
      conf = scriptElement.text()
      try
        _.defaults(config, ($j.parseJSON conf))
        return true
      catch e
        throw new AppEngine.Helpers.Error "Config: Unable to parse template config for '#{el.attr('name')}'", e, conf
    else
      return false

  #This creates config properties from script->text/template
  if !applyScriptConfig(config, el.children().first())
    applyScriptConfig(config, el.siblings().next())

  config["id"] = el.attr('name')
  config["el"] = el

  return config


helpers.getTypeFromConfig = (config = {}, defaultType) ->
  type
  if config['type']
    type = helpers.getTypeFromTypeName(config['type'])

  #log as debug console
  if type == defaultType
    console.debug "Type: Default '#{type.getName()}' being used for element"
  else if type
    console.debug "Type: '#{config['type']}' being used for element"
  else if defaultType
    type = defaultType
    console.debug "Type: Default type '#{defaultType.getName()}' being used for element"
  else
    throw new AppEngine.Helpers.Error "Type: config error when no default specified", (new Error "Type: not found for element"), config

  return type

helpers.getTypeFromTypeName = (typeName) ->
  #check the registry first
  type = AppEngine.registryGetTypeFromTypeShortName(typeName)

  if(!type)
    types = helpers.getObjectByPath typeName, $OuterScope
    if(types and types.length > 0)
      type = types[0]

  return type

helpers.createObjectFromType = (config, type, cb) ->
  #go through each config property to see if there are nested components that need to be instantiated first
  instantiateObject = (config) ->
    #create a new object of 'type'
    obj
    try
      obj = new type config
    catch e
       throw new AppEngine.Helpers.Error "createObjectFromType: Error creating new type '#{type.getName()}'", e

    complete = ->
      cb(obj) if cb

    if _.isFunction(obj.initialise)
      #this has an initialise function which must take a callback
      try
        obj.initialise complete
        return obj
      catch e
         throw new AppEngine.Helpers.Error "createObjectFromType: Error calling Initialise on type '#{type.getName()}'", e
    else
      #this doesnt contain an init function so doesnt require a callback
      complete()
      return obj

  #get all sub-objects that need to be initialised from the config
  itemsToPreInitialise = []
  if(_.isObject(config))
    _.each(config, (value, name) ->
      if _.isObject(value) and value.type
        value.__name = name
        itemsToPreInitialise.push value
    )

  if itemsToPreInitialise.length > 0
    #Object has other objects to initialise before 

    onAllComplete = ->
      instantiateObject(config)

    eachSubComponent = (conf, cb) ->
      #create each sub component
      onEachComplete = (item) ->
        config[conf.__name] = item
        cb(item)

      helpers.getObjectByConfig conf, { page: config.page }, null, onEachComplete

    #create each of the sub components
    helpers.asyncCallEach itemsToPreInitialise, eachSubComponent, onAllComplete
  else
    instantiateObject(config)


helpers.getObjectByConfig = (config, defaultConfig, defaultType, cb) ->
  #set all the default values of this config
  _.defaults config, defaultConfig

  type = helpers.getTypeFromConfig(config, defaultType)

  #create a new object of 'type'
  helpers.createObjectFromType(config, type, cb)


helpers.mergeArrays = (arr1, arr2) ->
  return arr1 if !arr2 || arr2.length == 0
  return arr2 if !arr1 || arr1.length == 0

  return _.union(arr1, arr2)


