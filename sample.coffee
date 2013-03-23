$(".sample-form").on "submit.app", (event) ->
	event.preventDefault()

$(".sample-form input").errorLite animation:
	type: "fade"
	speed: "fast"
	easing: "linear"
	extra:
		margin: 3