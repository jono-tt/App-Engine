#<< AppEngine/Behaviours

describe "AppRouter specs", ->

  Behaviours.expectRequiredParameters(AppEngine.Routers.AppRouter, ["pageManager", "parameterParser"])

  describe "Initialise", ->
    it "should set the correct properties", ->
      pm = jasmine.createSpyObj("PageManager", ["on"])
      pp = jasmine.createSpyObj("ParameterParser", ["on"])

      router = new AppEngine.Routers.AppRouter({
        pageManager: pm,
        parameterParser: pp
      })

      expect(router.pageManager).toEqual(pm)
      expect(router.parameterParser).toEqual(pp)

  describe "Route Change", ->
    pp = null
    pm = null

    beforeEach ->
      pm = jasmine.createSpyObj("PageManager", ["navigateToPage", "navigateToDefaultPage"])
      pp = jasmine.createSpyObj("ParameterParser", ["parseParameters"])

    it "should navigate to test1", ->
      params = [ { pageName: "test1", params: null } ]
      pp.parseParameters.andReturn(params)

      router = new AppEngine.Routers.AppRouter({
        pageManager: pm,
        parameterParser: pp
      })

      router.routeChange("url and params")
      expect(pm.navigateToPage).toHaveBeenCalled()

      #call the navigationComplete (successful)
      pm.navigateToPage.calls[0].args[1]()
      expect(router.previousParams).toEqual("url and params")

    it "should cancel navigation and go back", ->
      params = [ { pageName: "test1", params: null } ]
      pp.parseParameters.andReturn(params)

      router = new AppEngine.Routers.AppRouter({
        pageManager: pm,
        parameterParser: pp
      })

      spyOn(router, "navigate")
      router.previousParams = "test2"

      router.routeChange("url and params")
      expect(pm.navigateToPage).toHaveBeenCalled()

      #call the cancelNavigation callback
      pm.navigateToPage.calls[0].args[2]()

      expect(router.navigate).toHaveBeenCalledWith("test2", {trigger: false, replace: true})

    it "should navigate to default page with no pages parsed", ->
      params = []
      pp.parseParameters.andReturn(params)

      router = new AppEngine.Routers.AppRouter({
        pageManager: pm,
        parameterParser: pp
      })

      router.routeChange("not null")
      expect(pm.navigateToPage).not.toHaveBeenCalled()
      expect(pm.navigateToDefaultPage).toHaveBeenCalled()

    it "should navigate to default page null parameters", ->
      router = new AppEngine.Routers.AppRouter({
        pageManager: pm,
        parameterParser: pp
      })

      router.routeChange(undefined)
      expect(pm.navigateToPage).not.toHaveBeenCalled()
      expect(pm.navigateToDefaultPage).toHaveBeenCalled()