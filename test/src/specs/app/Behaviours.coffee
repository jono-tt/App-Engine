###
This file contains wrappers for test Behaivours that can be applied in other Specs
###
@Behaviours = {
  ###
  Makes sure that a class/type is expecting to initialise with certain options
    It also enforces a 2 way acknowledgement of required options
  ###
  expectRequiredParameters: (type, expectedParameterNames) ->
    originalType = type
    paramList = {}
    baseExpectedParams = []

    #check is this is an Abstract type
    if(type.isAbstract && type.isAbstract())
      type = class A extends type

    #add the super classes parameters so that they arent in the tests
    if originalType.__super__ && originalType.__super__.constructor && originalType.__super__.constructor.expectedParameters
      baseExpectedParams = originalType.__super__.constructor.expectedParameters
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
      #if this has expectedParameters then make sure we are testing for all expected params
      if(originalType.expectedParameters)
        it "should be testing for all expected parameters", ->
          diff = _.difference(originalType.expectedParameters, baseExpectedParams)
          expect(expectedParameterNames).toEqual(diff)


      for name in expectedParameterNames
        #build each test case for expected parameters
        params = _.clone(paramList) if _.toArray(paramList).length > 0
        doTest(name, params)
        paramList[name] = name

  ###
  Ensure that this class/type is abstract
  ###
  expectAbstract: (type) ->
    describe "Abstract", ->
      it "should be an abstract class/type", ->
        if(type.isAbstract && type.isAbstract())
          return

        expect("Should have failed").toEqual("because class/type should be abstract")


}