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

    @page.on("beforePageHide", @beforePageHide.createDelegate(@))
    @page.on("afterPageShown", @afterPageShown.createDelegate(@))
    @page.on("beforePageShown", @beforePageShown.createDelegate(@))
    @page.on("pageNavigationCancelled", @pageNavigationCancelled.createDelegate(@))

    super(cb)

  afterPageShown: (oldPage, params) ->
    @logger.warn "afterPageShown", oldPage, params

    m = ->
      @el.html("test: " + (Math.ceil(Math.random() * 1000)))

    setTimeout(m.createDelegate(@), 2000)

  beforePageShown: (continueCb, cancelCb, oldPage, params) ->
    @logger.warn "beforePageShown", oldPage, params
    continueCb()

  beforePageHide: (continueCb, cancelCb, newPage, params) ->
    if params and params.k
      continueCb();
    else
      cancelCb("because i wanted to");

  pageNavigationCancelled: (page) ->
    @logger.warn("I stopped navigation: #{page.id}")


class GTest extends AppEngine.Components.GlobalComponent
