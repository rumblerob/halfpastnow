var history_counter = 0;

$(function() {
  console.log(history);
  window.addEventListener("popstate", function(e) {
    history_counter--;
    var query = e.target.location.search;
    if(query != "") {
      console.log(query);
      console.log(parsequery(query));
      modal(parsequery(query));
    } else {
      demodal();
    }
      
    console.log(e);
  });
  
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
    demodal();
  });

  $('.mode .overlay .window').click(function(event) {
    event.stopPropagation();
  });
  
  $('a[linkto]').click(function() {
    modal({type:$(this).attr("linkto"), id: $(this).attr("href")});
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
/*
function forward() {
  history.pushState(thing, thing.type + " mode", "?" + thing.type + "_id=" + thing.id);
  history_counter++; 
}

function backAll() {
  history.go(-1 * history_counter);
  history_counter = 0;
}
*/
function modal(thing) {
  if(!thing) {
    $('.mode').hide();
  }

  $('.mode').hide();
  $('.mode.' + thing.type).show();

  //var offset = { width: 60, height: 60 };
  //$('.mode.' + thing.type + ' .window').width($(window).width() - offset.width * 2);
  //$('.mode.' + thing.type + ' .window').height($(window).height() - offset.height * 2);
  //$('.mode.' + thing.type + ' .window').css({ left: offset.width, top: offset.height });
}