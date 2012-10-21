#<< AppEngine/Objects/StrictObject

class ShowHideTransitionHandler extends AppEngine.Objects.StrictObject
  @expectedParameters = AppEngine.Helpers.mergeArrays(_super.expectedParameters, [])
  @applyParameters = AppEngine.Helpers.mergeArrays(_super.applyParameters, ['duration'])

  constructor: (options) ->
    super(options)
    @duration = 500 if !@duration

  doTransition: (oldPage, newPage, cb) ->
    logger = @logger
    duration = @duration

    oldPage.el.addClass("transition-out") if oldPage
    newPage.el.addClass("transition-in")
    newPage.el.removeClass("hide")

    complete = ->
      logger.debug "Fade In complete for page '#{newPage.id}'"
      newPage.el.removeClass("transition-in")
      newPage.el.removeAttr('style')
      cb()

    fadedOut = ->
      if oldPage
        logger.debug "Fade Out complete for page '#{oldPage.id}'"
        oldPage.el.addClass('hide')
        oldPage.el.removeAttr('style')
        oldPage.el.removeClass("transition-out") 

      logger.debug "Fading in page '#{newPage.id}' in #{duration} milliseconds"
      newPage.el.fadeIn(duration, complete)


    if(oldPage)
      logger.debug "Fading out page '#{oldPage.id}' in #{duration} milliseconds css"
      oldPage.el.fadeOut(duration, fadedOut)
    else
      fadedOut()
