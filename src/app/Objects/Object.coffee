class Object
  _.extend(@prototype, Backbone.Events)

  constructor: (conf) ->
    #Setup static logger for each class extending this
    @__proto__.logger = new AppEngine.Helpers.Logger(@) if !@__proto__.logger