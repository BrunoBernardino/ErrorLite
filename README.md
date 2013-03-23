# errorLite - A Lightweight & Simple jQuery Input Validation Plugin

errorLite is a lightweight & simple jQuery input validation  plugin. Currently at version 2.0, it's now built in CoffeeScript, compiled to unminified and minified JavaScript.

It's built off of Chapter 2 of Pro jQuery Plugins ( http://projqueryplugins.com ).

## Usage

Get https://raw.github.com/BrunoBernardino/ErrorLite/master/jquery.errorlite.min.js and https://raw.github.com/BrunoBernardino/ErrorLite/master/jquery.errorlite.css, include them in your site and call the following (supposing you'd want input validation on all inputs in a .sample-form form element):

```javascript
$(".sample-form input").errorLite({
	'animation': {
		'type': "fade",
		'speed': "fast",
		'easing': "linear",
		'extra': {
			'margin': 3
		}
	}
});
```

If you don't want to validate automatically, set 'autoCheck' option as false, and to validate a field, after initializing, use:

```javascript
$('.sample-form input[name="email"]').errorLite('validate');
```

It will return false if the field is not valid, true if it is valid.

## Features

* HTML5 type attribute usage
* 6 default validation types (alphanumeric, alphanumeric-extended, email, url, number, slug)
* Required and Max Length validations
* 2 "show" animation types: "fade" and "slide"
* Callback support for when the "show" animation finishes
* 2 error positions: "inside" and "outside"

## Dev features

* Namespaced events
* jQuery 1.9.1 tested
* Callable plugin methods
* CoffeeScript & SCSS

## Available Options & Default Values

* dataType:            "type" # data-* property to check for the field/validation type
* dataErrorTitle:      "errorTitle" # data-* property to check for the error title
* dataErrorHelp:       "errorHelp" # data-* property to check for the error help
* errorRequiredTitle:  "Required"
* errorRequiredHelp:   "This field is required."
* errorMaxLengthTitle: "Too Big"
* errorMaxLengthHelp:  "This field's value is too big. The maximum number of characters for it is {maxLength}."
* autoCheck:           true # If true, validate the field when the plugin is initialized
* errorClass:          "errorLite-error"
* position:            "inside" # Supports 'inside' and 'outside'
* animation:
	* type:       "fade" # Supports 'fade' and 'slide'
	* speed:      "fast"
	* easing:     "swing"
	* onComplete: $.noop
	* extra:
		* margin: 3 # Integer, the number of pixels to be "inside" or "outside" the input