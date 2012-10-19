#<< AppEngine/Helpers/Helpers

class StrictObject extends Backbone.Events
  @expectedParameters: []
  @applyParameters: []
  @isAbstract: -> @ == StrictObject

  constructor: (conf) ->
    #check that this is not an abstract class
    if @__proto__.constructor.isAbstract()
      throw new Error "Unable to create instance of Abstract class '#{@.__proto__.constructor.getName()}'"

    #Check that all config params were passed through correctly
    AppEngine.Helpers.assertParametersExist @.__proto__.constructor.expectedParameters, conf
    AppEngine.Helpers.applyToObject @__proto__.constructor.applyParameters, conf, @

