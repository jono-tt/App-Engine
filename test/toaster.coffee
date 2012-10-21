# => SRC FOLDER
toast

	folders: {
		'src/specs/app': 'AppEngine'
		'src/integration-tests/app': 'AppEngine'
	}

	# EXCLUDED FOLDERS (optional)
	# exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

	# => VENDORS (optional)
	vendors: [
		'vendors/jasmine-1.2.0/jasmine.js',
		'vendors/jasmine-1.2.0/jasmine-html.js'
	]

	# => OPTIONS (optional, default values listed)
	bare: true
	packaging: false
	expose: 'window'
	minify: false

	# => HTTPFOLDER (optional), RELEASE / DEBUG (required)
	httpfolder: '../www/test-js'
	release: '../www/test-js/tests.js'
	debug: '../www/test-js/tests-debug.js'
	#http://localhost/App-Engine/test/html/js/toaster/AppEngine/Helpers/Helpers.js"