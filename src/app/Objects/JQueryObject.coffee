#<< AppEngine/Objects/StrictObject

class JQueryObject extends AppEngine.Objects.StrictObject
  @expectedParameters = AppEngine.Helpers.mergeArrays(_super.expectedParameters, ['el'])
  @applyParameters = AppEngine.Helpers.mergeArrays(_super.applyParameters, ['el'])

  @isAbstract: -> @ == JQueryObject

  constructor: (options) ->
    try
      super options
    catch e
      throw new AppEngine.Helpers.Error "#{@constructor.getName()}: Creating new instance '#{options.id}'", e
