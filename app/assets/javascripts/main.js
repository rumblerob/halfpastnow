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
	
	$('#content .main .events li').click(function() {
		modal({type: "event", id: $(this).attr("event_id")});
	});
	
	$('#content .main .events li .venue').click(function(event) {
		event.stopPropagation();
		modal({ type: "venue", id: 1});
	});
	
	$('.mode .overlay').click(function() {
			$(this).parent().hide();
			history.pushState({}, "main mode", "/events");
	});
});

function modal(thing) {
	var offset = { width: 60, height: 60 };
	history.pushState(thing, thing.type + " mode", "/events?" + thing.type + "_id=" + thing.id);
	$('.mode.' + thing.type + ' .window').width($(window).width() - offset.width * 2);
	$('.mode.' + thing.type + ' .window').height($(window).height() - offset.height * 2);
	$('.mode.' + thing.type + ' .window').css({ left: offset.width, top: offset.height });
	$('.mode.' + thing.type).show();
}