help = AppEngine.Helpers

describe "Helpers Spec", ->
  describe "Assert Helpers", ->
    it "should ensure that an paramsect exists", ->
      expect(->
        help.assertExists(undefined, "error message")
        ).toThrow(new Error("error message"))

      #no error message
      expect(help.assertExists("exists", "no error message"))

    it "should assert a list of parameters exist on an paramsect", ->
      paramsNames = ["foo", "bar"]
      params = { foo: '1', bar: '2'}

      help.assertParametersExist(paramsNames, params)

    it "should fail assertion a list of missed parameter", ->
      paramsNames = ["foo", "bar"]
      params = { foo: '1' }

      expect(->
        help.assertParametersExist(paramsNames, params)
        ).toThrow(new Error("The constructor expects the parameter 'bar' to be passed in as a config parameter"))

  describe "applyToObject", ->
    it "should apply a list of params to an paramsect", ->
      paramsNames = ["foo", "bar", "too"]
      params = { foo: '1', bar: '2' }
      appliedparams = {}

      help.applyToObject(paramsNames, params, appliedparams)

      expect(appliedparams.foo).toEqual('1')
      expect(appliedparams.bar).toEqual('2')
      expect(appliedparams.too).toEqual(undefined)

  describe "getObjectByPath", ->
    obj = { foo: { bar: 1 }}

    it "should get the default property if the passed in value does not exist", ->
      ret = help.getObjectByPath("not.exists", obj, "default return")
      expect(ret).toEqual "default return"

    it "should get the default property if the path is not set", ->
      ret = help.getObjectByPath(null, obj, "default return")
      expect(ret).toEqual "default return"

    it "should get the path value if the path is valid", ->
      ret = help.getObjectByPath("foo.bar", obj, "was valid")
      expect(ret).toEqual [1]

  describe "asyncCallEach", ->
    it "should call each item in the list and once finished call the complete callback", ->
      num = 0
      itemList = [ "foo", "bar", "too" ]

      onEachItem = (item, cb, index) ->
        expect(index).toEqual(num)
        num += 1
        cb(item)

      onCompleteAll = jasmine.createSpy("onCompleteAll")

      help.asyncCallEach(itemList, onEachItem, onCompleteAll)

      expect(onCompleteAll).toHaveBeenCalledWith(itemList)
      expect(num).toEqual(itemList.length)


  describe "Configuration", ->
    it "should get a config from an element", ->
      el = new MockJQueryObject({
        attributes: {
          name: "test"
        },
        data: {
          foo: "2",
          bar: "3"
        }
      })

      conf = help.getConfigFromElement(el)
      expect(conf.id).toEqual("test")
      expect(conf.el).toEqual(el)
      expect(conf.foo).toEqual("2")
      expect(conf.bar).toEqual("3")


  describe "Types from Config", ->
    it "should get a default type from a config", ->
      type = help.getTypeFromConfig({}, Object)
      expect(type).toEqual(Object)

    it "should error without default type", ->
      getType = ->
        help.getTypeFromConfig({}, null)

      expect(getType).toThrow(new Error "Type: config error when no default specified")

    it "should get a type from a config", ->
      type = help.getTypeFromConfig({
        type: 'String'
        }, Object)

      expect(type).toEqual(String)

    it "should get a type from a type name", ->
      type = help.getTypeFromTypeName "String"
      expect(type).toEqual String


  describe "Create Object from Type", ->
    it "should create a new String", ->
      cb = jasmine.createSpy "callback"
      help.createObjectFromType "Foo Bar", String, cb
      expect(cb).toHaveBeenCalledWith "Foo Bar"

    it "should fail on creation", ->
      class Fail
        constructor: ->
          throw new Error "should fail"

      expect(->
        help.createObjectFromType null, Fail
      ).toThrow(new Error "createObjectFromType: Error creating new type 'Fail'")

    it "should fail on initialise", ->
      class Fail
        initialise: ->
          throw new Error "should fail"

      expect(->
        help.createObjectFromType null, Fail
      ).toThrow(new Error "createObjectFromType: Error calling Initialise on type 'Fail'")

    it "should correctly call initialise", ->
      class Success
        initialise: (callback) ->
          callback()

      cb = jasmine.createSpy("init finished")

      help.createObjectFromType null, Success, cb

      expect(cb).toHaveBeenCalled()


  describe "Create Object from Config", ->
    it "should set the default configs", ->
      callback = jasmine.createSpy("callback")

      help.getObjectByConfig("foo", { bar: '2' }, String, callback)

      mergedConfig = "foo"
      mergedConfig.bar = '2'

      expect(callback).toHaveBeenCalledWith(mergedConfig)

  describe "Merge Arrays", ->
    arr1 = [1, 2, 3]
    arr2 = [3, 4, 5]

    it "should return array1 if array 2 has no items", ->
      ret = help.mergeArrays(arr1, null)
      expect(ret).toEqual arr1

      ret = help.mergeArrays(arr1, [])
      expect(ret).toEqual arr1

    it "should return array2 if array 1 has no items", ->
      ret = help.mergeArrays(null, arr2)
      expect(ret).toEqual arr2

      ret = help.mergeArrays(null, arr2)
      expect(ret).toEqual arr2

    it "should return the merged arrays", ->
      ret = help.mergeArrays(arr1, arr2)

      expect(arr1.length).toEqual(3)
      expect(arr2.length).toEqual(3)
      expect(ret.length).toEqual(5)





