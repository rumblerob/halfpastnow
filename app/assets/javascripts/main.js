$(function() {
	$('#content .sidebar .inner .filter.distance .distances .selected').click(function(event) {
			event.stopPropagation();
			$('#content .sidebar .inner .filter.distance .distances').toggleClass("focus");
	});
	
	$('#content .sidebar .inner .filter.distance .distances span').not('.selected').click(function(event) {
		event.stopPropagation();
		$('#content .sidebar .inner .filter.distance .distances .selected').html($(this).html());
		$('#content .sidebar .inner .filter.distance .distances').removeClass('focus');
	});
	
	$('html').click(function() {
			$('#content .sidebar .inner .filter.distance .distances').removeClass('focus');
	});
	
	$('#content .sidebar .inner .filter.price span').click(function() { 
		$(this).toggleClass('selected');	
	});
	
	$('#content .sidebar .inner .filter.day span').click(function() { 
		$(this).toggleClass('selected');	
	});
	
	$('#content .sidebar .inner .filter.date .date ').datepicker();
});