App-Engine


External Dependencies:
  nodejs         - http://coffeescript.org/
  toaster        - https://github.com/serpentem/coffee-toaster

Internal Dependencies: (Files included in Vendors folders)
  Jasmine        - http://pivotal.github.com/jasmine/
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
        "transitionHandlerOptions": {
          "type": "[A Transition Handler] default: ShowHideTransitionHandler"
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


Page:
  Page Configs:
    data-is-default-page
    data-is-not-found-page
    data-is-error-page

  Public Properties:
    currentPageParams - the pages last known parameters - gets set before the showPage event gets fired

  Events:
    beforePageHide
      continueCallback - to be called if must continue
      cancelCallback - to be called if callback must be cancelled, to notify up the stack that page change must be reverted
      newPage - the page that we are transitioning to
      pageParams - parameters passed into new page

    beforePageShown:
      oldPage - the page that is being replaced
      pageParams - the params this page will have after the transition has completed

    pageShown:
      oldPage - the page that was replaced
      pageParams - the params this page now has

    afterPageShown:
      oldPage - the page that was replaced
      pageParams - the params this page now has



Global Components: (any component that has an attribute as follows)
  name: unique name (*required)
  data-scope: (*required)
    "global" - This the root Page Manager for the entire Application. This means you can have components living outside of pages
    "pageManager" - This is the PageManager that this component lives in (ie. If this is a child page's component the child PageManager registry will be used)
    "page" - The component will be available to all sub-components but only on the current page
  





      
