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

  $('#content .sidebar .inner .filter.date .date ').datetimepicker({
    ampm: true,
    showMinute: false,
    hour: (new Date()).getHours(),
    dateFormat: 'D m/d',
    timeFormat: 'h:mmtt',
    separator: ' @ '
  });

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
  
  if(thing.type === "event") {
    $.getJSON('/events/show/' + thing.id + '.json', function(event) {
      console.log(event);

      start = new Date(event.occurrences[0].start);
      $('.mode.event .time.one').html(start.toString("dddd, MMMM d"));
      $('.mode.event .time.two').html(start.toString("h:mmtt"));
      
      $('.mode.event h1').html(event.title);
      $('.mode.event .venue a').html(event.venue.name);
      $('.mode.event .venue a').attr("href", event.venue.id);
      $('.mode.event .address.one').html(event.venue.address);
      $('.mode.event .address.two').html(event.venue.city + ", " + event.venue.state + " " + event.venue.zip);
      $('.mode.event .price span').html(event.price);
      $('.mode.event .map').attr("src","http://maps.googleapis.com/maps/api/staticmap?size=430x170&zoom=15&maptype=roadmap&markers=color:red%7C" + event.venue.latitude  +  "," + event.venue.longitude + "&style=feature:all|hue:0x000001|saturation:-50&sensor=false");
      $('.mode').hide();
      $('.mode.event').show();
    });
  } else {
    $.getJSON('/venues/show/' + thing.id + '.json', function(venue) {
      console.log(venue);
      
      $('.mode.venue h1').html(venue.name);
      $('.mode.venue .address.one').html(venue.address);
      $('.mode.venue .address.two').html(venue.city + ", " + venue.state + " " + venue.zip);
      $('.mode.venue .map').attr("src","http://maps.googleapis.com/maps/api/staticmap?size=430x170&zoom=15&maptype=roadmap&markers=color:red%7C" + venue.latitude  +  "," + venue.longitude + "&style=feature:all|hue:0x000001|saturation:-50&sensor=false");
      $('.mode').hide();
      $('.mode.venue').show();
    });
  }
  
  
}

