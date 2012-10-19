#create a registry for the application and the components that can be registered by a class name
componentRegistry = {}
__t('AppEngine').registerComponent = (className, component) ->
  if componentRegistry[className]
    console.debug "RegisterComponent: Overriding component #{componentRegistry[className].getName()} with selector '#{className}' for component #{component.getName()}"
  else
    console.debug "RegisterComponent: Setting component #{component.getName()} by selector '#{className}'"

  componentRegistry[className] = component


__t('AppEngine').registryGetTypeFromTypeShortName = (name) ->
  return componentRegistry[name] if componentRegistry[name]
  return null


__t('AppEngine').initialiseComponentRegistry = (scopes) ->
  #taverse all components and add to registry

  scopes = [scopes] if !_.isArray(scopes)

  loopEachObject = (component) ->
    if component and !component.__has_been_checked and _.isObject component
      component.__has_been_checked = true

      #check all functions
      for componentName in _.functions(component)
        #check all the functions of this function
        for name in _.functions(component[componentName])
          if name == 'getShortNameIdentification'
            if !component[componentName].isAbstract()
              #this is the function for getting the Component Identification
              #eg. Objects['Page']['getShortNameIdentification']()
              try 
                className = component[componentName][name]()
                if className
                  AppEngine.registerComponent(className, component[componentName])
                  break;
              catch e
                console.log("dfa")
                throw new AppEngine.Helpers.Error "Cannot get the correct IdentificationClass for the component: '#{componentName}'", e
            else
              console.debug "RegisterComponent: Component #{component[componentName].getName()} is marked as Abstract, not adding to registry"


      #go through each sub object
      for name in _.keys(component)
        loopEachObject component[name]

  for scope in scopes
    loopEachObject scope