#<< AppEngine/Components/AppEngineComponent

class PageComponent extends AppEngine.Components.AppEngineComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['page'])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, ['page'])
  @isAbstract: -> @ == PageComponent

  constructor: (options = {})->
    super options

  initialise: (cb) ->
    super(cb)