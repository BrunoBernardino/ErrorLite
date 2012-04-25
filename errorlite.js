/***
ErrorLite by Bruno Bernardino - www.brunobernardino.com
v1.0 - 2012/04/25
***/
jQuery.fn.errorLite = function(options) {
	var $ = jQuery;
	var opts = $.extend({}, $.fn.errorLite.defaults, options);

	this.each(function() {
		var theID = 'errorLite-' + $(this).attr('id');

		if ($('#' + theID).length == 0 || $('#' + theID).html() != opts.msgTxt) {
			if ($('#' + theID).length != 0) $('#' + theID).click();
			$(this).after('<div id="' + theID + '" class="errorLite">' + opts.msgTxt + '</div>');
			$('#' + theID).fadeIn(opts.fadeSpeed);
			$(this).addClass('error');

			$('#' + theID).css('top', $(this).offset().top);
			$('#' + theID).css('left', $(this).offset().left + $(this).outerWidth() - $('#' + theID).outerWidth());//-- Placing the error inside the input, on the right. Change these values to position the error wherever you want.
		}
	});

	$('.errorLite').live('click',function() {
		var pID = $(this).attr('id').replace('errorLite-','');
		$(this).fadeOut('fast', function() {
			$(this).remove();
			$('#' + pID).removeClass('error');
		});
	});
};

//-- Default errorLite options
jQuery.fn.errorLite.defaults = {
	msgTxt: 'Required',
	fadeSpeed: 'fast'
};