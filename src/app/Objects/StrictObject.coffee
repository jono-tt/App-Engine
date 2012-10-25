#<< AppEngine/Helpers/Helpers
#<< AppEngine/Helpers/Logger
#<< AppEngine/Objects/Object

class StrictObject extends AppEngine.Objects.Object
  @expectedParameters: []
  @applyParameters: []
  @isAbstract: -> @ == StrictObject

  constructor: (options) ->
    super(options)
    
    #check that this is not an abstract class
    if @__proto__.constructor.isAbstract()
      throw new Error "Unable to create instance of Abstract class '#{@.__proto__.constructor.getName()}'"

    #Check that all config params were passed through correctly
    if @.__proto__.constructor.expectedParameters.length > 0
      if options
        AppEngine.Helpers.assertParametersExist @.__proto__.constructor.expectedParameters, options
      else
        throw new Error "StrictObject: There are required parameters but the options are not defined"

    @applyConfig(options) if options

  applyConfig: (options) ->
    _.each @__proto__.constructor.applyParameters, (name) ->
      @applyConfigAttrib name, options[name]
    , @

  applyConfigAttrib: (name, attribValue) ->
    @[name] = attribValue




