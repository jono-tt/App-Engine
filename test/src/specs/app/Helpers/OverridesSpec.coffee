describe "Overrides specs", ->
  describe "RegExp Overrides", ->
    it "should have an additional prototype function of getMatches", ->
      expect(RegExp.prototype.getMatches).toBeDefined()

    describe "getMatches response", ->
      text = "This 1 equals 1 but should match three 1's"
      reg = "([^1]*)"

      it "should return the correct count of matches", ->
        expect(new RegExp(reg).getMatches(text).length).toEqual(4)

      it "should return the correct match captures", ->
        matches = new RegExp(reg).getMatches(text)
        expect(matches[0][1]).toEqual("This ")
        expect(matches[3][1]).toEqual("'s")

  describe "Function Overrides", ->
    describe "getName of function", ->
      it "should return the correct name of an Class", ->
        class MyDummy
          isCorrect: -> true

        expect(MyDummy.getName()).toEqual("MyDummy")


    describe "createDelegate of function", ->
      it "should call the function with the correct scope", ->
        scopeObject = {}

        myTestFunction = ->
          @ == scopeObject

        delegate = myTestFunction.createDelegate(scopeObject)
        expect(delegate()).toBeTruthy()

        delegate = myTestFunction.createDelegate(this)
        expect(delegate()).not.toBeTruthy()
