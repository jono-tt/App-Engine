#<< AppEngine/Components/AppEngineComponent

class GlobalComponent extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ["id", "scope"])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ["id", "scope"])
  @isAbstract: -> @ == GlobalComponent

  constructor: (options = {})->
    super options

  initialise: (cb) ->
    super(cb)