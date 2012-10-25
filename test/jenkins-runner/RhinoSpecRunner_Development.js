load("lib/env.rhino.1.2.js");
Envjs.scriptTypes['text/javascript'] = true;

//setup the reporters
var runTests = function() {
  console.log("");

  console.log("Rhino Spec runner: starting tests");

  load("lib/env.rhino.1.2.js");
  Envjs.scriptTypes['text/javascript'] = true;
  
  window.continuous = true;
  window.location = "../../www/RhinoSpecRunner.html";
};

var lastModifiedTests;
var lastModifiedApp;
var app_js_file = "../../www/js/app.js";
var test_js_file = "../../www/test-js/tests.js";

//loop forever until manual stop
while(true) {
  var reloadApp = false;
  var reloadTests = false;

  var temp = new java.io.File(app_js_file).lastModified();
  if(temp && temp != lastModifiedApp) {
    reloadApp = true;
  }
  lastModifiedApp = temp;

  temp = new java.io.File(test_js_file).lastModified();
  if(temp && temp != lastModifiedTests) {
    reloadTests = true;
  }
  lastModifiedTests = temp;

  if(reloadApp || reloadTests) {
    //execute test again and allow reporter completed to do tests for the file changes
    console.log("");
    console.log("Rhino: launching new test environment");
    //var o = { f : sync(runTests) };
    var t = spawn(runTests); //function() { o.f(); });
    console.log("Rhino: waiting for tests to complete running");
    t.join();
    console.log('');
    console.log('Rhino: Tests complete, waiting on more changes...');
    console.log('');
    console.log('');
  } else {
    java.lang.Thread.sleep(2000);
  }
};



