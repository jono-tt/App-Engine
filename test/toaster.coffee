# => SRC FOLDER
toast

	folders: {
		'src/specs': 'AppEngine'
		'src/integration-tests': 'AppEngine'
	}

	# EXCLUDED FOLDERS (optional)
	# exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

	# => VENDORS (optional)
	vendors: [
		'vendors/jasmine-1.2.0/jasmine.js',
		'vendors/jasmine-1.2.0/jasmine-html.js'
	]

	# => OPTIONS (optional, default values listed)
	bare: false
	packaging: true
	expose: 'this'
	minify: false

	# => HTTPFOLDER (optional), RELEASE / DEBUG (required)
	httpfolder: '../www/test-js'
	release: '../www/test-js/tests.js'
	debug: '../www/test-js/tests-debug.js'
	#http://localhost/App-Engine/test/html/js/toaster/AppEngine/Helpers/Helpers.js"