describe "Object specs", ->
  describe "triggerWithCallback", ->
    it "should call success if there are no listeners", ->
      complete = jasmine.createSpy("complete")
      cancel = jasmine.createSpy("cancel")

      me = new AppEngine.Objects.Object

      me.triggerWithCallback("test", complete, cancel)

      expect(complete).toHaveBeenCalled()
      expect(cancel).not.toHaveBeenCalled()

    it "should callback once all listeners have called success", ->
      me = new AppEngine.Objects.Object

      listener = spyOn( { listener: (success, fail, text) ->
        success()
        }, 'listener'
      ).andCallThrough()

      complete = jasmine.createSpy("complete")
      cancel = jasmine.createSpy("cancel")

      me.on("test", listener);
      me.on("test", listener);
      me.on("test", listener);

      me.triggerWithCallback("test", complete, cancel, "foo")

      expect(listener).toHaveBeenCalled()
      expect(listener.calls.length).toEqual(3)
      expect(listener.calls[0].args.length).toEqual(3)
      expect(listener.calls[0].args[2]).toEqual("foo")

      expect(complete).toHaveBeenCalled()
      expect(cancel).not.toHaveBeenCalled()

    it "should call the fail listener", ->
      me = new AppEngine.Objects.Object

      listener = spyOn( { listener: (success, fail, text) ->
        fail()
        }, 'listener'
      ).andCallThrough()

      complete = jasmine.createSpy("complete")
      cancel = jasmine.createSpy("cancel")

      me.on("test", listener);
      me.on("test", listener);

      me.triggerWithCallback("test", complete, cancel)

      expect(listener).toHaveBeenCalled()
      expect(listener.calls.length).toEqual(2)

      expect(complete).not.toHaveBeenCalled()
      expect(cancel).toHaveBeenCalled()

