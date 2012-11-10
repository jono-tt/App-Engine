describe "ShowHideTransitionHandler specs", ->
  Behaviours.expectRequiredParameters(AppEngine.Transitions.ShowHideTransitionHandler, [])
      
  describe "doTransition", ->
    it "should do transion to newPage without old page", ->
      newPage = new MockJQueryObject()
      callback = jasmine.createSpy("callback")

      th = new AppEngine.Transitions.ShowHideTransitionHandler({ duration: 1000 })
      th.doTransition(null, { el: newPage }, callback)

      expect(newPage.fadeIn).toHaveBeenCalled()
      expect(newPage.addClass).toHaveBeenCalledWith("transition-in")
      expect(newPage.removeClass).toHaveBeenCalledWith("hide")
      expect(newPage.removeAttr).toHaveBeenCalledWith("style")
      expect(newPage.fadeIn.calls[0].args[0]).toEqual(1000)

      expect(callback).toHaveBeenCalled()

    it "should do transion from oldPage to newPage", ->
      newPage = new MockJQueryObject()
      oldPage = new MockJQueryObject()
      callback = jasmine.createSpy("callback")

      th = new AppEngine.Transitions.ShowHideTransitionHandler()
      th.doTransition({ el: oldPage}, { el: newPage }, callback)

      expect(newPage.fadeIn).toHaveBeenCalled()
      expect(newPage.addClass).toHaveBeenCalledWith("transition-in")
      expect(newPage.removeClass).toHaveBeenCalledWith("hide")
      expect(newPage.removeAttr).toHaveBeenCalledWith("style")
      expect(newPage.fadeIn.calls[0].args[0]).toEqual(500)

      expect(oldPage.addClass).toHaveBeenCalledWith("transition-out")
      expect(oldPage.fadeOut).toHaveBeenCalled()
      expect(oldPage.fadeOut.calls[0].args[0]).toEqual(500)
      expect(oldPage.addClass).toHaveBeenCalledWith("hide")
      expect(oldPage.removeAttr).toHaveBeenCalledWith("style")
      expect(oldPage.removeClass).toHaveBeenCalledWith("transition-out")

      expect(callback).toHaveBeenCalled()
