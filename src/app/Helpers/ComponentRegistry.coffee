#<< AppEngine/Helpers/Logger

#create a registry for the application and the components that can be registered by a class name
AppEngine = __t('AppEngine')
AppEngine.componentRegistry = {}
logger = null

AppEngine.registerComponent = (className, component) ->
  if AppEngine.componentRegistry[className]
    logger.debug "RegisterComponent: Overriding component #{AppEngine.componentRegistry[className].getName()} with selector '#{className}' for component #{component.getName()}"
  else
    logger.debug "RegisterComponent: Setting component #{component.getName()} by selector '#{className}'"

  AppEngine.componentRegistry[className] = component


AppEngine.registryGetTypeFromTypeShortName = (name) ->
  return AppEngine.componentRegistry[name] if AppEngine.componentRegistry[name]
  return null


AppEngine.initialiseComponentRegistry = (scopes) ->
  #taverse all components and add to registry
  logger = new AppEngine.Helpers.Logger(@)

  scopes = [scopes] if !_.isArray(scopes)

  loopEachObject = (component, checkedList) ->
    if component and !component.__has_been_checked and _.isObject component
      component.__has_been_checked = true
      checkedList.push(component)

      #check all functions
      if component.prototype instanceof AppEngine.Components.AppEngineComponent
        if !component.prototype.constructor.isAbstract()
          #this is the function for getting the Component Identification
          #eg. Objects['Page']['getShortNameIdentification']()
          if component.prototype.constructor.getShortNameIdentification
            try 
              className = component.prototype.constructor.getShortNameIdentification()

              if className
                AppEngine.registerComponent(className, component)
              else
                logger.warn "RegisterComponent: Component #{component.getName()} does not have a short name, not adding to registry"
            catch e
              throw new AppEngine.Helpers.Error "Cannot get the correct IdentificationClass for the component: '#{component.getName()}'", e
          else 
            logger.debug "RegisterComponent: Component #{component.getName()} does not have a short name, not adding to registry"
        else
          logger.debug "RegisterComponent: Component #{component.getName()} is marked as Abstract, not adding to registry"

      #go through each sub object
      for name in _.keys(component)
        loopEachObject component[name], checkedList

  checkedCompList = []
  for scope in scopes
    loopEachObject scope, checkedCompList

  for comp in checkedCompList
    delete comp.__has_been_checked
