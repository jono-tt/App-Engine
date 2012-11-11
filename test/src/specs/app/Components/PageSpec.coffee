#<< AppEngine/Behaviours
#<< AppEngine/Mocks/MockPageManager

describe "Page specs", ->
  Page = AppEngine.Components.Page
  Behaviours.expectRequiredParameters(AppEngine.Components.Page, ["id", "pageManager", "transitionHandler"])

  pageManager = null
  pageEl = null
  page = null

  beforeEach ->
    AppEngine.initialiseComponentRegistry({})

    pageManager = new MockPageManager()
    pageEl = $j("<div id='test_page'> <div name='child1' data-type='TestComponent'/> </div>")

    page = new Page({
        id: "test_page_" + (Math.ceil(Math.random() * 1000)),
        pageManager: pageManager,
        transitionHandler: jasmine.createSpyObj("MockTransitionHandler", ["doTransition"]),
        el: pageEl,
        wrappedElement: {
          children: [ { 
            id: "child1",
            name: "child1",
            el: pageEl.find("[name='child1']") 
          }]
        }
      })

  describe "Initialise", ->
    beforeEach ->
      class TestComponent extends AppEngine.Components.AppEngineComponent
        constructor: (options) ->
          super(options)

      AppEngine.registerComponent("TestComponent", TestComponent)

    it "should initialise with one component", ->
      onInit = jasmine.createSpy("onInit")
      page.initialise(onInit)

      expect(onInit).toHaveBeenCalled()
      expect(page.childPageManager).not.toBeDefined()
      expect(page.children.length).toEqual(1)

    it "should initialise with ChildPageManager created", ->
      childPageComponents = [{
        childPageComponent: "Child Page Component"
      }]
      pageManager.getPageElementsFromComponents.andReturn(childPageComponents)

      page.initialise(->)
      expect(page.childPageManager).toBeDefined()
      expect(page.childPageManager.initialise).toHaveBeenCalled()
      expect(page.childPageManager.components).toEqual(childPageComponents)

    it "should initialise with first Component being a Page added to the ChildPageManager", ->
      pageManager.isPageComponent.andReturn(true)

      page.initialise(->)
      expect(page.childPageManager).toBeDefined()
      expect(page.childPageManager.initialise).toHaveBeenCalled()
      expect(page.childPageManager.components[0]).toEqual(page.wrappedElement.children[0])

    describe "Global Component", ->
      class TestComponent extends AppEngine.Components.GlobalComponent
      beforeEach ->
        AppEngine.registerComponent("TestComponent", TestComponent)

      it "should be added to Page scope", ->
        page.wrappedElement.children[0].el.data("scope", "page")
        page.initialise(->)
        expect(page.globalComponents).toBeDefined()
        expect(page.globalComponents["child1"]).toBeDefined()

      it "should be added to PageManager global components", ->
        page.wrappedElement.children[0].el.data("scope", "not Page Scope")
        page.initialise(->)
        expect(pageManager.addGlobalComponent).toHaveBeenCalled()
        expect(pageManager.addGlobalComponent.calls[0].args[1]).toEqual("not Page Scope")

      it "should listen to the dispose event on the component", ->
        page.wrappedElement.children[0].el.data("scope", "page")
        spyOn(TestComponent.prototype, "on")

        page.initialise(->)
        expect(page.globalComponents["child1"].on).toHaveBeenCalled()
        expect(page.globalComponents["child1"].on.calls[0].args[0]).toEqual("dispose")
        expect(typeof page.globalComponents["child1"].on.calls[0].args[1]).toEqual("function")

      it "should cleanup the Global registry on component dispose", ->
        page.wrappedElement.children[0].el.data("scope", "page")
        page.initialise(->)
        expect(page.globalComponents["child1"]).toBeDefined()
        page.globalComponents["child1"].dispose()
        expect(page.globalComponents["child1"]).not.toBeDefined()

  describe "Dispose", ->
    it "should dispose child manager", ->
      page.childPageManager = new MockPageManager()
      disposeSpy = page.childPageManager.dispose

      page.dispose()

      expect(disposeSpy).toHaveBeenCalled()
      expect(page.childPageManager).toBeNull()

  describe "Re-initialise", ->
    it "should reinitialise the page", ->
      spyOn(page, "initialise")
      spyOn(page, "dispose")

      pageWrapper = "page wrapper"
      cb = "Completed Callback"

      page.reinitialise(pageWrapper, cb)

      expect(page.dispose).toHaveBeenCalled()
      expect(page.initialise).toHaveBeenCalledWith(cb)
      expect(page.wrappedElement).toEqual(pageWrapper)

  describe "Page Navigation", ->
    params = { test: "page params"}
    success = null
    cancel = null
    beforeEach ->
      success = jasmine.createSpy("success")
      cancel = jasmine.createSpy("cancel")

    describe "beforePageShow", ->
      beforeEach ->
        spyOn(page, "beforeChildPageShow")

      describe "fetchStratergy", ->
        beforeEach ->
          spyOn(page, "loadPageContent")

        it "should load page from url", ->
          page.url = "test url"

          page.beforePageShow page, params, [], success, cancel
          expect(page.loadPageContent).toHaveBeenCalled()
          expect(page.loadPageContent.calls[0].args[0]).toEqual "test url"

        it "should not load page from url if already loaded", ->
          page.url = "test url"
          page.isLoaded = true
          page.beforePageShow page, params, [], success, cancel
          expect(page.loadPageContent).not.toHaveBeenCalled()
          expect(page.beforeChildPageShow).toHaveBeenCalled()

        it "should re-load page from url because fetchStratergy = 'always'", ->
          page.url = "test url"
          page.isLoaded = true
          page.fetchStratergy = "always"
          page.beforePageShow page, params, [], success, cancel
          expect(page.loadPageContent).toHaveBeenCalled()

      describe "triggerWithCallback", ->
        beforeEach ->
          spyOn(page, "triggerWithCallback")

        it "should be called with the correct parameters", ->
          oldPage = "oldPage"
          page.beforePageShow oldPage, params, [], success, cancel
          expect(page.triggerWithCallback).toHaveBeenCalled()
          args = page.triggerWithCallback.calls[0].args
          expect(args.length).toEqual 5
          expect(args[0]).toEqual "beforePageShown"
          expect(args[3]).toEqual oldPage
          expect(args[4]).toEqual params

        it "should call success", ->
          oldPage = "oldPage"
          page.beforePageShow oldPage, params, [], success, cancel
          expect(page.triggerWithCallback).toHaveBeenCalled()
          args = page.triggerWithCallback.calls[0].args
          
          #call success
          args[1]()
          expect(page.beforeChildPageShow).toHaveBeenCalled()

        it "should call cancel and trigger 'pageNavigationCancelled'", ->
          oldPage = "oldPage"
          spyOn(page, "trigger")

          page.beforePageShow oldPage, params, [], success, cancel
          expect(page.triggerWithCallback).toHaveBeenCalled()
          args = page.triggerWithCallback.calls[0].args
          
          #call cancel
          args[2]("cancel message")
          expect(cancel).toHaveBeenCalledWith "cancel message"
          expect(page.trigger).toHaveBeenCalledWith "pageNavigationCancelled", page

        it "should not be called if oldPage = page", ->
          page.beforePageShow page, params, [], success, cancel
          expect(page.triggerWithCallback).not.toHaveBeenCalled()
          expect(page.beforeChildPageShow).toHaveBeenCalled()

    describe "beforeChildPageShow", ->
      nextPageWithParam = null
      beforeEach ->
        nextPageWithParam = {
          page: {
            beforePageShow: jasmine.createSpy("beforePageShow")
          },
          params: {
            foo: "bar"
          }
        }

      it "should call success if no childPageManager present", ->
        page.beforeChildPageShow page, [], success, cancel
        expect(success).toHaveBeenCalled()

      it "should continue if there are no parameters for the child page manager", ->
        page.childPageManager = new MockPageManager()

        page.beforeChildPageShow page, [], success, cancel
        expect(success).toHaveBeenCalled()

      it "should call beforePageShow on the next page from the ChildPageManager", ->
        page.childPageManager = new MockPageManager()
        page.childPageManager.getPageAndParamsFromList.andReturn(nextPageWithParam)

        page.beforeChildPageShow page, [], success, cancel
        expect(nextPageWithParam.page.beforePageShow).toHaveBeenCalled()
        args = nextPageWithParam.page.beforePageShow.calls[0].args
        expect(args.length).toEqual 5
        expect(args[0]).toEqual page
        expect(args[1]).toEqual nextPageWithParam.params
        expect(args[2]).toEqual []

      it "should call beforePageShow which calls cancel", ->
        page.childPageManager = new MockPageManager()
        page.childPageManager.getPageAndParamsFromList.andReturn(nextPageWithParam)

        page.beforeChildPageShow page, [], success, cancel
        expect(nextPageWithParam.page.beforePageShow).toHaveBeenCalled()
        args = nextPageWithParam.page.beforePageShow.calls[0].args
        expect(typeof args[4]).toEqual "function"
        args[4]("cancelled")
        expect(success).not.toHaveBeenCalled()
        expect(cancel).toHaveBeenCalledWith("cancelled")

      it "should call beforePageShow which calls success", ->
        page.childPageManager = new MockPageManager()
        page.childPageManager.getPageAndParamsFromList.andReturn(nextPageWithParam)

        page.beforeChildPageShow page, [], success, cancel
        expect(nextPageWithParam.page.beforePageShow).toHaveBeenCalled()
        args = nextPageWithParam.page.beforePageShow.calls[0].args
        expect(typeof args[3]).toEqual "function"
        args[3]()
        expect(success).toHaveBeenCalled()
        expect(cancel).not.toHaveBeenCalled()


    describe "pageShow", ->
      it "should call the transition handler if oldPage is set", ->
        oldPage = "old page"
        page.pageShow(oldPage, params, {}, ->)

        expect(page.transitionHandler.doTransition).toHaveBeenCalled()
        args = page.transitionHandler.doTransition.calls[0].args
        expect(args.length).toEqual 3
        expect(args[0]).toEqual oldPage
        expect(args[1]).toEqual page

      it "should not call the transition handler if oldPage = page", ->
        cb = jasmine.createSpy("complete")
        page.pageShow(page, params, {}, cb)
        expect(page.transitionHandler.doTransition).not.toHaveBeenCalled()
        expect(cb).toHaveBeenCalled()

      it "should trigger pageShown event", ->
        cb = jasmine.createSpy("complete")
        spyOn(page, "trigger")

        page.pageShow(page, params, {}, cb)
        expect(page.trigger).toHaveBeenCalledWith("pageShown", page, params)
        expect(cb).toHaveBeenCalled()

      it "should call afterPageHide on old page after transition complete", ->
        oldPage = jasmine.createSpyObj("oldPage", ["afterPageHide"])
        cb = jasmine.createSpy("complete")

        page.pageShow(oldPage, params, {}, cb)
        expect(page.transitionHandler.doTransition).toHaveBeenCalled()
        args = page.transitionHandler.doTransition.calls[0].args
        #page transition complete call
        args[2]()

        expect(oldPage.afterPageHide).toHaveBeenCalledWith(page)

      it "should correctly set the page parameters", ->
        cb = jasmine.createSpy("complete")
        pageParams = page.getPageParams()
        paramsChanged = jasmine.createSpy("paramsChanged")
        pageParams.on("change:test", paramsChanged)

        page.pageShow(page, params, {}, cb)
        expect(cb).toHaveBeenCalled()
        expect(paramsChanged).toHaveBeenCalled()

    describe "afterPageShow", ->
      it "should trigger afterPageShown event", ->
        cb = jasmine.createSpy("complete")
        spyOn(page, "trigger")

        page.afterPageShow(page, params, {}, cb)
        expect(page.trigger).toHaveBeenCalledWith("afterPageShown", page, params)
        expect(cb).toHaveBeenCalled()

      it "should navigate to childPageManager", ->
        cb = jasmine.createSpy("complete")
        spyOn(page, "trigger")
        page.childPageManager = jasmine.createSpyObj("childPageManager", ["navigateToPage"])
        
        page.afterPageShow(page, params, {}, cb)
        expect(page.childPageManager.navigateToPage).toHaveBeenCalled()
        expect(page.childPageManager.navigateToPage.calls[0].args.length).toEqual 2

        #call complete callback
        page.childPageManager.navigateToPage.calls[0].args[1]()
        expect(cb).toHaveBeenCalled()

    describe "beforePageHide", ->
      beforeEach ->
        spyOn(page, "beforeChildPageHide")

      it "should call beforeChildPageHide if newPage = page", ->
        page.beforePageHide page, {}, "childPageParams", success, cancel

        expect(page.beforeChildPageHide).toHaveBeenCalled()
        args = page.beforeChildPageHide.calls[0].args
        expect(args[0]).toEqual "childPageParams"
        expect(args[1]).toEqual success
        expect(typeof args[2]).toEqual "function"

        #call cancel
        args[2]("cancelled")
        expect(cancel).toHaveBeenCalledWith "cancelled"

      it "should call triggerWithCallback if newPage != page", ->
        spyOn(page, "triggerWithCallback")
        page.beforePageHide "newPage", {}, "childPageParams", success, cancel
        expect(page.triggerWithCallback).toHaveBeenCalled()

      it "should trigger event beforePageHide and call success", ->
        params = "foo params"
        newPage = "newPage"

        eventListener = (success, fail, np, ps) ->
          expect(np).toEqual newPage
          expect(ps).toEqual params
          success()

        page.on("beforePageHide", eventListener)

        page.beforePageHide "newPage", params, "childPageParams", success, cancel
        expect(page.beforeChildPageHide).toHaveBeenCalled()

      it "should trigger event beforePageHide and call cancel", ->
        params = "foo params"
        newPage = "newPage"

        eventListener = (success, cancel, np, ps) ->
          expect(np).toEqual newPage
          expect(ps).toEqual params
          cancel()
          
        page.on("beforePageHide", eventListener)

        page.beforePageHide "newPage", params, "childPageParams", success, cancel
        expect(page.beforeChildPageHide).not.toHaveBeenCalled()
        expect(cancel).toHaveBeenCalled()

      it "should trigger event pageNavigationCancelled on cancel", ->
        eventListener = (success, cancel, np, ps) ->
          cancel()
        page.on("beforePageHide", eventListener)
        spyOn(page, "trigger")

        page.beforePageHide "newPage", "params", "childPageParams", success, cancel
        expect(page.trigger).toHaveBeenCalledWith("pageNavigationCancelled", page)
        
    describe "beforeChildPageHide", ->
      nextPageWithParam = null
      beforeEach ->
        nextPageWithParam = {
          page: {
            beforePageHide: jasmine.createSpy("beforePageHide")
          },
          params: {
            foo: "bar"
          }
        }

      it "should call success if no childPageManager present", ->
        page.beforeChildPageHide [], success, cancel
        expect(success).toHaveBeenCalled()

      it "should continue if there are no parameters for the child page manager", ->
        page.childPageManager = new MockPageManager()

        page.beforeChildPageHide [], success, cancel
        expect(success).toHaveBeenCalled()

      describe "Calls to ChildPageManger", ->
        args = null
        beforeEach ->
          page.childPageManager = new MockPageManager()
          page.childPageManager.getPageAndParamsFromList.andReturn(nextPageWithParam)

          page.beforeChildPageHide [], success, cancel
          expect(page.childPageManager.beforeCurrentPageHide).toHaveBeenCalled()
          args = page.childPageManager.beforeCurrentPageHide.calls[0].args

        it "should call beforePageHide on the current page in the ChildPageManager", ->
          expect(args.length).toEqual 5
          expect(args[0]).toEqual nextPageWithParam.page
          expect(args[1]).toEqual nextPageWithParam.params
          expect(args[2]).toEqual []

        it "should call beforePageHide which calls cancel", ->
          expect(typeof args[4]).toEqual "function"
          args[4]("cancelled")
          expect(success).not.toHaveBeenCalled()
          expect(cancel).toHaveBeenCalledWith("cancelled")

        it "should call beforePageHide which calls success", ->
          expect(typeof args[3]).toEqual "function"
          args[3]()
          expect(success).toHaveBeenCalled()
          expect(cancel).not.toHaveBeenCalled()

    describe "afterPageHide", ->
      it "should trigger 'afterPageHidden' if newPage != page", ->
        spyOn(page, "trigger")
        page.afterPageHide("new page")
        expect(page.trigger).toHaveBeenCalledWith "afterPageHidden", "new page"
  
      it "should not trigger 'afterPageHidden' if newPage == page", ->
        spyOn(page, "trigger")
        page.afterPageHide(page)
        expect(page.trigger).not.toHaveBeenCalled()


