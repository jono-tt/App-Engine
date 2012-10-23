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
      "pageDefaultConfig": {
        "type": "[A Page Type]"
      },
      "pageClassIdentifier": "pseudo-page is default"
    }
  }


Page Configs:
data-is-default-page
data-is-not-found-page
data-is-error-page