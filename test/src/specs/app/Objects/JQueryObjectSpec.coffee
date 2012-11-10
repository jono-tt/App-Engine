#<< AppEngine/Behaviours

describe "JQueryObject specs", ->
  Behaviours.expectRequiredParameters(AppEngine.Objects.JQueryObject, ["el"])
  Behaviours.expectAbstract(AppEngine.Objects.JQueryObject)
