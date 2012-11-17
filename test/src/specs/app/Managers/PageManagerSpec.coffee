#<< AppEngine/Behaviours

describe "PageManager specs", ->
  PageManager = AppEngine.Managers.PageManager

  Behaviours.expectRequiredParameters(PageManager, ["appConfig", "parameterParser"])

  describe "Default Config", ->
    it "should create a new PageManager with default options", ->
      options = {
        appConfig: {
          foo: "bar"
        },
        parameterParser: "Parameter Parser"
      }

      pm = new PageManager(options)

      expect(pm.pageClassIdentifier).toEqual "pseudo-page"
      expect(pm.appConfig).toEqual options.appConfig
      expect(pm.components).toEqual []
      expect(pm.specialPages).toEqual({ defaultPage: null, notFoundPage: null, errorPage: null})

      expect(pm.pageDefaultConfig).toEqual({
        type: AppEngine.Components.Page.getShortNameIdentification(),
        transitionHandler: {
          type: "AppEngine.Transitions.ShowHideTransitionHandler",
          duration: 500
        }
      })

  describe "Initialise", ->
    it "should initialise all pages", ->
      components = [
        { comp: "foo1", el: $j("<div id='foo' class='ae-comp pseudo-page' />") }
      ]

      pm = new PageManager( { 
        appConfig: {}, 
        components: components,
        parameterParser: "Parameter Parser"
      } )
      spyOn(pm, "createAllPages")

      pm.initialise(->)
      expect(pm.createAllPages).toHaveBeenCalled()
      expect(pm.createAllPages.calls[0].args[0]).toEqual components

    it "should initialise all global components", ->
      components = [
        { comp: "foo2", el: $j("<div class='ae-comp' data-scope='page' />") }
      ]

      pm = new PageManager( { 
        appConfig: {}, 
        components: components,
        parameterParser: "Parameter Parser"
      } )
      spyOn(pm, "createGlobalComponents")

      pm.initialise(->)
      expect(pm.createGlobalComponents).toHaveBeenCalled()
      expect(pm.createGlobalComponents.calls[0].args[0]).toEqual components

    it "should initialise all components and callback", ->
      pm = new PageManager( { 
        appConfig: {}, 
        components: [],
        parameterParser: "Parameter Parser"
      } )
      cb = jasmine.createSpy("callback")
      pm.initialise(cb)
      expect(cb).toHaveBeenCalled()

  describe "Page Stack List", ->
    it "should return only the current page of the if there is no parentManager", ->
      pm = new PageManager( { 
        appConfig: {}, 
        components: [],
        parameterParser: "Parameter Parser"
      } )
      pm.currentPage = "test page"

      res = pm.getCurrentPageStack()
      expect(res).toEqual [pm.currentPage]

    it "should return page stack of multiple page managers", ->
      pm1 = new PageManager( { 
        appConfig: {}, 
        components: [],
        parameterParser: "Parameter Parser"
      } )
      pm1.currentPage = "test page 1"

      pm2 = new PageManager( { 
        appConfig: {}, 
        components: [],
        parameterParser: "Parameter Parser",
        parentManager: pm1
      } )
      pm2.currentPage = "test page 2"

      pm3 = new PageManager( { 
        appConfig: {}, 
        components: [],
        parameterParser: "Parameter Parser",
        parentManager: pm2
      } )
      pm3.currentPage = "test page 3"

      res = pm3.getCurrentPageStack()
      expect(res).toEqual [pm1.currentPage, pm2.currentPage, pm3.currentPage]

    it "should return only the nested pages without current page for BasePageStack", ->
      pm1 = new PageManager( { 
        appConfig: {}, 
        components: [],
        parameterParser: "Parameter Parser"
      } )
      pm1.currentPage = "test page 1"

      pm2 = new PageManager( { 
        appConfig: {}, 
        components: [],
        parameterParser: "Parameter Parser",
        parentManager: pm1
      } )
      pm2.currentPage = "test page 2"

      res = pm2.getBasePageStack()
      expect(res).toEqual [pm1.currentPage]

  describe "doPageNavigation", ->
    pm = null
    parentManager = null
    page1 = null
    page2 = null

    beforeEach ->
      spyOn(AppEngine.Helpers, "changeDocumentLocation")

      pm = new PageManager( { 
        appConfig: {},
        components: [],
        parameterParser: jasmine.createSpyObj("parameterParser", ["encodePagesToUrl"])
      } )

      page1 = new AppEngine.Components.Page({
        id: "foo_page_1",
        pageManager: pm,
        el: {},
        appConfig: {},
        wrappedElement: {},
        transitionHandler: "transitionHandler"
      })

      page2 = new AppEngine.Components.Page({
        id: "foo_page_2",
        pageManager: pm,
        el: {},
        appConfig: {},
        wrappedElement: {},
        transitionHandler: "transitionHandler"
      })

      parentManager = new PageManager( { 
        appConfig: {},
        components: [],
        parameterParser: "parser"
      } )

    it "should navigate to page by page name", ->
      pm.pages = {
        "foo_page_1": page1
      }

      pm.doPageNavigation("foo_page_1", { foo: "bar" })
      expect(pm.parameterParser.encodePagesToUrl).toHaveBeenCalledWith( [{ pageName: "foo_page_1", params: { foo: "bar" }}] )

    it "should get the parent pageManager pages as a full page stack to navigate to", ->
      pm.parentManager = parentManager
      parentManager.currentPage = page2

      pm.doPageNavigation(page1, { foo: "bar" })
      expect(pm.parameterParser.encodePagesToUrl).toHaveBeenCalledWith( [
        { pageName: "foo_page_2", params: {}},
        { pageName: "foo_page_1", params: { foo: "bar" }}
      ] )


    it "should navigate to the correct page", ->
      pm.parameterParser.encodePagesToUrl.andReturn("http://my_url")
      pm.doPageNavigation(page1, {})

      expect(AppEngine.Helpers.changeDocumentLocation).toHaveBeenCalledWith("http://my_url")


  



