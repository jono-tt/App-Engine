(function() {
    if (! jasmine) {
        throw new Exception("jasmine library does not exist in global namespace!");
    }

    /**
     * This is just a wrapper that throws System.exit(1) if there are any failing tests
     *
     * Usage:
     *
     * jasmine.getEnv().addReporter(new jasmine.JavaProcessFailOnErrorReporter());
     * jasmine.getEnv().execute();
     */
    var JavaProcessFailOnErrorReporter = function() {
    };

    JavaProcessFailOnErrorReporter.prototype = {
        reportRunnerResults: function(runner) {
            if((this.executed_specs - this.passed_specs) > 0) {
                java.lang.System.exit(1);
            }
        },

        reportRunnerStarting: function(runner) {
            this.started = true;
            this.executed_specs = 0;
            this.passed_specs = 0;
        },

        reportSpecResults: function(spec) {
            if (spec.results().passed()) {
                this.passed_specs++;
                resultText = "Passed.";
            }
        },

        reportSpecStarting: function(spec) {
            this.executed_specs++;
        },

        reportSuiteResults: function(suite) {

        }
    };

    // export public
    jasmine.JavaProcessFailOnErrorReporter = JavaProcessFailOnErrorReporter;
})();
