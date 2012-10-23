#<< AppEngine/Components/PageComponent

class SayHello extends AppEngine.Components.PageComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, [])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, [])

  @getShortNameIdentification: -> "say-hello"

  constructor: (config)->
    super config
    @logger.debug "SayHello: object has been created"

  initialise: (cb) ->
    @logger.debug "SayHello: has been initialised"
    @logger.debug @el.html()
    m = ->
      @el.html("test")

    setTimeout(m.createDelegate(@), 2000)

    super(cb)