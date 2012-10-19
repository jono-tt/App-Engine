# => SRC FOLDER
toast

	folders: {
		'src/app': 'AppEngine'
	}

	# EXCLUDED FOLDERS (optional)
	# exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

	# => VENDORS (optional)
	vendors: [
		'vendors/js/console_helper.js',
		'vendors/js/jquery/jquery_min_1.7.1.js', 
		'vendors/js/jquery/jquery.imgpreload.min.js', 
		'vendors/js/underscore_min_1.3.3.js', 
		'vendors/js/underscore.string.min.js',
		'vendors/js/json2.js',
		'vendors/js/json_path_0.8.0.js',
		'vendors/js/js_simple_date_format.js',
		'vendors/js/backbone_min_0.9.2.js'
	]

	# => OPTIONS (optional, default values listed)
	bare: false
	packaging: true
	expose: 'this'
	minify: false

	# => HTTPFOLDER (optional), RELEASE / DEBUG (required)
	httpfolder: 'js'
	release: 'www/js/app.js'
	debug: 'www/js/app-debug.js'