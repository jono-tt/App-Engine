#<< AppEngine/TestHelpers

describe "GlobalComponent", ->
  expectRequiredParameters(AppEngine.Components.GlobalComponent, ["id", "scope"])

