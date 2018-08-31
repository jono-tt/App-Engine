App-Engine


External Dependencies:
  nodejs         - http://coffeescript.org/
  toaster        - https://github.com/serpentem/coffee-toaster

Internal Dependencies: (Files included in Vendors folders)
  Jasmine        - https://jasmine.github.io/
  BackboneJS     - http://backbonejs.org/
  JQuery         - http://jquery.com/
  Underscore     - http://underscorejs.org/
  JSON Path      - http://code.google.com/p/jsonpath/

Documentation:
  https://github.com/netzpirat/codo



Application Configs:
  {
    "language": "en",
    "logger": {
      "debug": "true",
      "error": "true",
      "log": "true",
      "warn": "true"
    },
    "componentRegistryNamespaces": ["AppEngine"],
    "pageManager": {
      "type": "ClassName [Default AppEngine.Managers.PageManager]",
      "pageDefaultConfig": {
        "type": "[A Page Type]",
        "transitionHandler": {
          "type": "[A Transition Handler] default: ShowHideTransitionHandler",
          "duration": 1000
        }
      },
      "pageClassIdentifier": "pseudo-page is default"
    },
    "parameterParser": {
      "type": "[A Parameter Parser Type] default: JsonParameterParser"
    },
    "router": {
      "type": "[A Router Type] default: AppRouter"
    }
  }


All Components:
  Components can be configured by:
    1)  Adding the class 'ae-comp'
    2)  Setting the attribute 'data-type' to a full class name or to the shortname for the component
    3)  Options for the class constructor can be set 2 ways:
      i)  As data attributes on the element:
        <div data-type='MyComponent' data-fade-in="true"></div>
      ii) As script templates:
        <span class="MyComponent" />
        <script name='config' type='text/template'>{ fadeIn: true }</script>
        OR
        <span class="MyComponent">
          <script name='config' type='text/template'>{ fadeIn: true }</script>
        </span>
        OR (with sub property types)
        <span class="MyComponent">
          <script name='config' type='text/template'>
            { 
              fadeIn: true,
              handler: {
                type: "FadeHandler",
                time: 100
              }
            }
          </script>
        </span>


Page:
  Page Configs:
    data-is-default-page
    data-is-not-found-page
    data-is-error-page

  Public Properties:
    currentPageParams - the pages last known parameters - gets set before the showPage event gets fired

  Events:
    beforePageHide
      continueCb - to be called if must continue
      cancelCb - to be called if callback must be cancelled, to notify up the stack that page change must be reverted
      newPage - the page that we are transitioning to
      pageParams - parameters passed into new page

    pageNavigationCancelled
      page - page that triggered the event

    beforePageShown:
      continueCb - Called to continue showing the page
      cancelCb - Called to cancel the page display (optional: If this is the first page then this option will be null)
      oldPage - the page that is being replaced
      pageParams - the params this page will have after the transition has completed

    afterPageHidden:
      newPage - the page that has replaced this page

    pageShown:
      oldPage - the page that was replaced
      pageParams - the params this page now has

    afterPageShown:
      oldPage - the page that was replaced
      pageParams - the params this page now has


AppEngineComponent:
  Events:
    dispose: (gets fired when the object is disposed of)
      component - the component that is getting disposed of



Global Components: (any component that has an attribute as follows)
  name: unique name (*required)
  data-scope: (*required)
    "global" - This the root Page Manager for the entire Application. This means you can have components living outside of pages
    "pageManager" - This is the PageManager that this component lives in (ie. If this is a child page's component the child PageManager registry will be used)
    "page" - The component will be available to all sub-components but only on the current page
  





      
