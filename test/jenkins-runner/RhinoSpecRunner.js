

//OVERRIDE THE BackboneHistory PROTOTYPE FOR NAVIGATION
  //The navigation is broken for StateChange. 
  //Override the window history state for Rhino Testing
var OldStart = Backbone.History.prototype.start;
Backbone.History.prototype.start = function(options) {
  options.pushState = true;
  window.history.pushState = function(params, title, frag) {};

  OldStart.call(this, options);
};

loadTemplate = function(templateLocation, cb) {
  var template = readFile(templateLocation);
  $j('#test-template-location').html(template);
  cb();
};

var jasmineEnv = jasmine.getEnv();
jasmineEnv.updateInterval = 1000;

//change the console so that output is generated on the STDOUT
jasmine.getGlobal().console = {
  info: console.info,
  warn: console.warn,
  log: console.log,
  debug: console.debug
};


jasmineEnv.addReporter(new jasmine.JUnitXmlReporter("target/reports/"));
jasmineEnv.addReporter(new jasmine.ConsoleReporter());

jasmineEnv.execute();


