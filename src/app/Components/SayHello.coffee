#<< AppEngine/Components/PageComponent
#<< AppEngine/Components/GlobalComponent

class SayHello extends AppEngine.Components.PageComponent
  @expectedParameters: AppEngine.Helpers.mergeArrays(_super.expectedParameters, [])
  @applyParameters: AppEngine.Helpers.mergeArrays(_super.applyParameters, [])

  @getShortNameIdentification: -> "say-hello"

  constructor: (options = {})->
    super options
    @logger.debug "SayHello: object has been created"

  initialise: (cb) ->
    @logger.debug "SayHello: has been initialised"
    @logger.debug @el.html()
    m = ->
      @el.html("test")

    setTimeout(m.createDelegate(@), 2000)

    @page.on("beforePageHide", @beforePageHide.createDelegate(@))
    @page.on("afterPageShown", @afterPageShown.createDelegate(@))
    @page.on("beforePageShown", @beforePageShown.createDelegate(@))

    super(cb)

  afterPageShown: (oldPage, params) ->
    @logger.log "afterPageShown", oldPage, params

  beforePageShown: (continueCb, cancelCb, oldPage, params) ->
    @logger.log "beforePageShown", oldPage, params
    if cancelCb
      cancelCb() 
    else
      continueCb()

  beforePageHide: (continueCb, cancelCb, newPage, params) ->
    if params and params.k
      continueCb();
    else
      cancelCb();



class GTest extends AppEngine.Components.GlobalComponent
