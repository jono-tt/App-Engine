#<< AppEngine/Behaviours

describe "StrictObject specs", ->
  Behaviours.expectRequiredParameters(AppEngine.Objects.StrictObject, [])
  Behaviours.expectAbstract(AppEngine.Objects.StrictObject)
