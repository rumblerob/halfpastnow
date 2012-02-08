window.addEventListener("popstate", function(e) {
  console.log(e);
  var query = e.target.location.search;
  if(query !== "") {
    modal(parsequery(query));
  } else {
    demodal();
  }
});

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

  $('.mode .overlay').click(function() {   
    history.pushState({}, "main mode", "/");
    demodal();
  });

  $('.mode .overlay .window').click(function(event) {
    event.stopPropagation();
  });
  
  $(".mode .window .menu li").click(function() {
    var index = $(this).index();
    $(this).parent().children("li").removeClass("selected");
    $(this).addClass("selected");
    $(this).parent().parent().children("div").removeClass("selected");
    $(this).parent().parent().children("div").eq(index).addClass("selected");
  });
  
  $('[linkto]').click(function(event) {
    var thing = {type:$(this).attr("linkto"), id: $(this).attr("href")};
    history.pushState(thing, thing.type + " mode", "?" + thing.type + "_id=" + thing.id);
    if($(this).is("#content .main .events li .venue")) {
       event.stopPropagation();
    }
    modal(thing);
    return false;
  });
});

//only works for one parameter. lol
function parsequery(query) {
  query = query.substring(1, query.length);
  var queryArr = query.split('=');
  if(queryArr[0] == "venue_id") {
    return { type: "venue", id: queryArr[1] };
  } else if(queryArr[0] == "event_id") {
    return { type: "event", id: queryArr[1] };
  } else {
    return null;
  }
}

function demodal() {
  modal();
}

function modal(thing) {
  if(!thing) {
    $('.mode').hide();
    return;
  }

  $('.mode').hide();
  $('.mode.' + thing.type).show();
}