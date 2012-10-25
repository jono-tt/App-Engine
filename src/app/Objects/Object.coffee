class Object
  _.extend(@prototype, Backbone.Events)

  constructor: (options = {}) ->
    #Setup static logger for each class extending this
    @__proto__.logger = new AppEngine.Helpers.Logger(@) if !@__proto__.logger


  #Trigger one or many events, firing all bound callbacks. Callbacks are
  # passed the same arguments as `trigger` is, apart from the event name
  # (unless you're listening on `"all"`, which will cause your callback to
  # receive the true name of the event as the first argument).
  triggerWithCallback: (event, complete, cancel) ->
    if !(calls = @_callbacks)
      complete()
      return @

    rest = Array.prototype.slice.call(arguments, 3);

    #run the events with callback events
    if (node = calls[event])
      tail = node.tail

      notificationList = []
      while ((node = node.next) != tail)
        notificationList.push node

      doCancel = false
      count = 0;

      calcCb = ->
        count++
        if count >= notificationList.length
          if doCancel
            cancel()
          else
            complete()

      cancelCb = ->
        doCancel = true
        calcCb()

      rest.unshift cancelCb
      rest.unshift calcCb

      for node in notificationList
        node.callback.apply(node.context or this, rest)

    else
      complete()
      
    return this