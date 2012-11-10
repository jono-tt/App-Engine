@expectRequiredParameters = (type, expectedParameterNames) ->
  originalType = type
  paramList = {}

  #check is this is an Abstract type
  if(type.isAbstract && type.isAbstract())
    type = class A extends type

  #add the super classes parameters so that they arent in the tests
  if originalType.__super__ && originalType.__super__.constructor
    for name in originalType.__super__.constructor.expectedParameters
      paramList[name] = name


  doTest = (name, params) ->
    it "should fail without parameter '#{name}'", ->
      try 
        new type params
        expect("Should have failed").toEqual("because parameter is required")
      catch e
        if e.getRootError
          message = e.getRootError().message
        else
          message = e.message
          
        expect(message).toEqual("The constructor expects the parameter '#{name}' to be passed in as a config parameter")

  describe "New Object", ->
    for name in expectedParameterNames
      #build each test case for expected parameters
      params = _.clone(paramList) if _.toArray(paramList).length > 0
      doTest(name, params)
      paramList[name] = name
      