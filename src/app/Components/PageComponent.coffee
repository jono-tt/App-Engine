#<< AppEngine/Components/AppEngineComponent

class PageComponent extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['page'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['page'])
  @isAbstract: -> @ == PageComponent

  constructor: (config)->
    super config

  initialise: (cb) ->
    super(cb)