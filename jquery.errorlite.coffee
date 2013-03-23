###
errorLite v2.0 by Bruno Bernardino | 2013.03.23 | https://github.com/BrunoBernardino/ErrorLite
###
# Helper function to generate a unique id, GUID-style. Idea from http://guid.us/GUID/JavaScript
helpers = generateID: ->
	S4 = ->
		(((1 + window.Math.random()) * 0x10000) | 0).toString(16).substring 1

	(S4() + S4() + "-" + S4() + "-4" + S4().substr(0, 3) + "-" + S4() + "-" + S4() + S4() + S4()).toLowerCase()

globals =
	options: {}

methods =
	init: (options) ->
		defaults =
			dataType:            "type" # data-* property to check for the field/validation type
			dataErrorTitle:      "errorTitle" # data-* property to check for the error title
			dataErrorHelp:       "errorHelp" # data-* property to check for the error help
			errorRequiredTitle:  "Required"
			errorRequiredHelp:   "This field is required."
			errorMaxLengthTitle: "Too Big"
			errorMaxLengthHelp:  "This field's value is too big. The maximum number of characters for it is {maxLength}."
			autoCheck:           true # If true, validate the field when the plugin is initialized
			errorClass:          "errorLite-error"
			position:            "inside" # Supports 'inside' and 'outside'
			animation:
				type:       "fade" # Supports 'fade' and 'slide'
				speed:      "fast"
				easing:     "swing"
				onComplete: $.noop
				extra:
					margin: 3 # Integer, the number of pixels to be "inside" or "outside" the input

		options = $.extend(defaults, options)
		globals.options = $.extend({}, options)

		@each ->
			$this = $(this)
			data = $this.data("errorLite")
			unless data
				$this.data "errorLite",
					target: $this

				# Trigger field validation, if autoCheck is true
				methods.validate.call this, options	if options.autoCheck

				# Bind blur to validate the field
				$(this).on "blur.errorLite", ->
					methods.validate.call this, options

				# Bind focusing on the field making the error go away
				$(this).on "focus.errorLite", ->
					methods.hideError.call this, options

	destroy: ->
		$(window).off ".errorLite"
		@each ->
			$this = $(this)
			data = $this.data("errorLite")
			$this.removeData "errorLite"

	validate: (options) ->
		if typeof options == "undefined"
			options = globals.options

		$this = $(this)
		validationType = ""
		isRequired = false
		maxLength = 0
		fieldValue = $(this).val()
		validationRegularExpression = null
		
		# Check .data(options.dataType) OR .attr('type') for the type of validation to check for
		switch $this.attr("type")
			when "email", "url", "number"
				validationType = $this.attr("type")
			when "tel"
				validationType = "alphanumeric-extended"
			else # "text"
				switch $this.data(options.dataType)
					when "alphanumeric", "alphanumeric-extended", "email", "url", "number", "slug"
						validationType = $this.data(options.dataType)
		
		# Check .prop('required') to see if the field is required
		isRequired = true if $this.prop("required")
		
		# Check .attr('maxlength') for the characters limit
		maxLength = window.parseInt($this.attr("maxlength"), 10)	if $this.attr("maxlength")
		
		# If there's no validation type, the field isn't required, and no maximum length to check for, there's nothing to validate.
		return true	if validationType is "" and not isRequired and maxLength <= 0
		
		# Make the actual validations for the type
		switch validationType
			when "alphanumeric"
				validationRegularExpression = /[^a-z0-9]/g
				if validationRegularExpression.test(fieldValue)
					methods.showError.call this,
						title: "Invalid"
						help: "This field's value isn't alphanumeric. It must consist only of numbers and/or (non-special) letters."
					, options
					return false
			when "alphanumeric-extended"
				# This regular expression will only match Basic Latin and Latin-1 Supplement special letters, but you can change it to support any kind of special characters how you wish. Here's a nice website to help you get the range you need: http://kourge.net/projects/regexp-unicode-block
				validationRegularExpression = /[^\u0000-\u00FFa-z0-9\-\._ ]/g
				if validationRegularExpression.test(fieldValue)
					methods.showError.call this,
						title: "Invalid"
						help: "This field's value isn't alphanumeric. It must consist only of numbers, letters, dots, underscores, dashes and spaces."
					, options
					return false
			when "email"
				# No need for a super complicated expression here. Note this is an expression of what it should be, not what it shouldn't.
				validationRegularExpression = /^\S+@\S+\.\S+$/g
				if fieldValue.length > 0 and not validationRegularExpression.test(fieldValue)
					methods.showError.call this,
						title: "Invalid"
						help: "This field's value isn't an email. It must be a valid email address."
					, options
					return false
			when "url"
				# No need for a super complicated expression here. Note this is an expression of what it should be, not what it shouldn't.
				validationRegularExpression = /^(http|ftp|https):\/\/\S+\.\S+$/g
				if fieldValue.length > 0 and not validationRegularExpression.test(fieldValue)
					methods.showError.call this,
						title: "Invalid"
						help: "This field's value isn't an URL. It must be a valid URL and start with http://, for example."
					, options
					return false
			when "number"
				validationRegularExpression = /[^\d]/g
				if validationRegularExpression.test(fieldValue)
					methods.showError.call this,
						title: "Invalid"
						help: "This field's value isn't a number. It must be a valid natural number."
					, options
					return false
			when "slug"
				validationRegularExpression = /[^a-z0-9\-_]/g
				if validationRegularExpression.test(fieldValue)
					methods.showError.call this,
						title: "Invalid"
						help: "This field's value isn't a valid slug. It must consist only of numbers, lowercase (non-special) letters, underscores and dashes."
					, options
					return false
		
		# Check if the field is required and empty
		if isRequired and fieldValue.length is 0
			methods.showError.call this,
				title: options.errorRequiredTitle
				help: options.errorRequiredHelp
			, options
			return false
		
		# Check if the field has a maximum length that's being exceeded
		if maxLength > 0 and fieldValue.length > maxLength
			methods.showError.call this,
				title: options.errorMaxLengthTitle
				help: options.errorMaxLengthHelp.replace("{maxLength}", maxLength)
			, options
			return false
		true

	showError: (errorData, options) ->
		if typeof options == "undefined"
			options = globals.options

		$this = $(this)
		
		# Check if an error already exists for the element, if so, do nothing
		return true	if $this.siblings("." + options.errorClass).length
		
		# Check if the input has a user-defined error title and help (and we're not checking for the global required and maxlength errors)
		errorData.title = $this.data(options.dataErrorTitle) if $this.data(options.dataErrorTitle) and errorData.title isnt options.errorRequiredTitle and errorData.title isnt options.errorMaxLengthTitle
		errorData.help = $this.data(options.dataErrorHelp) if $this.data(options.dataErrorHelp) and errorData.help isnt options.errorRequiredHelp and errorData.help isnt options.errorMaxLengthHelp
		generatedID = helpers.generateID.call(this)
		errorID = "errorLite-error-#{ generatedID }"
		errorHTML = "<div id=\"#{ errorID }\" class=\"#{ options.errorClass }\" title=\"#{ errorData.help }\">#{ errorData.title }</div>"
		
		# Add error inside input
		$this.after errorHTML
		
		# Position error inside or outside
		switch options.position
			when "outside"
				$("#" + errorID).css "margin-left": $this.outerWidth() + options.animation.extra.margin
			else # "inside"
				$("#" + errorID).css "margin-left": $this.outerWidth() - $("#" + errorID).outerWidth() - options.animation.extra.margin
		
		# Animate Error Showing
		switch options.animation.type
			when "slide"
				$("#" + errorID).slideDown options.animation.speed, options.animation.easing, options.animation.onComplete
			else # "fade"
				$("#" + errorID).fadeIn options.animation.speed, options.animation.easing, options.animation.onComplete
		
		# Bind clicking on error make the error go away
		$("#" + errorID).on "click.errorLite", (event) ->
			event.preventDefault()
			methods.hideError.call $this, options

	hideError: (options) ->
		if typeof options == "undefined"
			options = globals.options

		# Animate Error Hiding
		switch options.animation.type
			when "slide"
				$(this).siblings("." + options.errorClass).slideUp options.animation.speed, options.animation.easing, ->
					$(this).remove()
			else # "fade"
				$(this).siblings("." + options.errorClass).fadeOut options.animation.speed, options.animation.easing, ->
					$(this).remove()

	hideAllErrors: (options) ->
		if typeof options == "undefined"
			options = globals.options

		# Animate Error Hiding
		switch options.animation.type
			when "slide"
				$("." + options.errorClass).slideUp options.animation.speed, options.animation.easing, ->
					$(this).remove()
			else # "fade"
				$("." + options.errorClass).fadeOut options.animation.speed, options.animation.easing, ->
					$(this).remove()

$.fn.errorLite = (method) ->
	if methods[method]
		methods[method].apply this, Array::slice.call(arguments, 1)
	else if typeof method is "object" or not method
		methods.init.apply this, arguments
	else
		$.error "Method #{ method } does not exist on jQuery.errorLite"