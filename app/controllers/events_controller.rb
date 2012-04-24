require 'pp'
require 'open-uri'
require 'json'

class Price
  FREE = 0
  ONE = 5
  TWO = 10
  THREE = 25
end

# brittle as hell, because these have to change if we change the map size, and also if we change locales from Austin.
class ZoomDelta
  HighLatitude = 0.037808182 / 2
  HighLongitude = 0.02617836 / 2
  MediumLatitude = 0.0756264644 / 2
  MediumLongitude = 0.05235672 / 2
  LowLatitude = 0.30250564 / 2
  LowLongitude = 0.20942688 / 2


end

class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  
  
  def index

    @ZoomDelta = {
             11 => { :lat => 0.30250564 / 2, :long => 0.20942688 / 2 }, 
             13 => { :lat => 0.0756264644 / 2, :long => 0.05235672 / 2 }, 
             14 => {:lat => 0.037808182 / 2, :long => 0.02617836 / 2 }
            }

    @lat = 30.25
    @long = -97.75
    @zoom = 11

    # @events = Event.search params[:search]
    @events = Event.all

    if params[:location] && params[:location] != ""
      json_object = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + URI::encode(params[:location])).read)
      @lat = json_object["results"][0]["geometry"]["location"]["lat"]
      @long = json_object["results"][0]["geometry"]["location"]["lng"]
      @zoom = 14
    end

    @lat_delta = @ZoomDelta[@zoom][:lat]
    @long_delta = @ZoomDelta[@zoom][:long]
    @lat_low = @lat - @lat_delta
    @lat_high = @lat + @lat_delta
    @long_low = @long - @long_delta
    @long_high = @long + @long_delta

    # puts "from " + @lat_low.to_s + " to " + @lat_high.to_s
    # puts "from " + @long_low.to_s + " to " + @long_high.to_s

    # puts "events_size = " + @events.count.to_s

    # @events.each do |event|
    #   puts @lat_low.to_s + " ? " + event.venue.latitude.to_s + " ? " + @lat_high.to_s
    #   puts @long_low.to_s + " ? " + event.venue.longitude.to_s + " ? " + @long_high.to_s
    #   puts ((event.venue.latitude >= @lat_low) && (event.venue.latitude <= @lat_high) && (event.venue.longitude >= @long_low) && (event.venue.longitude <= @long_high))
    # end

    @events.select! do |event| 
      ((event.venue.latitude >= @lat_low) && (event.venue.latitude <= @lat_high) && (event.venue.longitude >= @long_low) && (event.venue.longitude <= @long_high))
    end

    # puts "new events_size = " + @events.count.to_s

    # if location is in params:
    #   geolocate and find lat/long
    #   filter on a bounding box with center at location = lat/long and zoom = high
    # else
    #   filter on a bounding box with center at location = center of austin and zoom = low

    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def fromRaw
    #before_filter :authenticate_user!
    authorize! :fromRaw, @user, :message => 'Not authorized as an administrator.'
    puts params

    if request.post? 
      puts "\n# POST\n"
      if(params["venue-type"] == "existing")
        params[:event].delete("venue_attributes")
      end

      puts params

      # params[:event]["occurrences_attributes"]["0"]["day_of_week"] = Date.parse(params[:event]["occurrences_attributes"]["0"]["start(1i)"] + "-" + params[:event]["occurrences_attributes"]["0"]["start(2i)"] + "-" + params[:event]["occurrences_attributes"]["0"]["start(3i)"]).wday
      @event = Event.new(params[:event])
      @event.save
    end

    if params[:delete_id]
      @dRawEvent = RawEvent.find(params[:delete_id])
      if @dRawEvent
        @dRawEvent.deleted = true
        @dRawEvent.save
      end
    end

    #get a random RawEvent from non-submitted/deleted RawEvents
    @rawEvent = RawEvent.first(:order => "RANDOM()", :conditions => "submitted IS NULL AND deleted IS NULL")
    @event = Event.new
    @occurrence = Occurrence.new({
      :start => @rawEvent.start,
      :end => @rawEvent.end
    })
    @venue = Venue.new({
      :name => @rawEvent.venue_name,
      :address => @rawEvent.venue_address,
      :city => @rawEvent.venue_city,
      :state => @rawEvent.venue_state,
      :zip => @rawEvent.venue_zip,
      :latitude => @rawEvent.latitude,
      :longitude => @rawEvent.longitude
    })
    @venueBlank = Venue.new
    
    render :layout => 'venues'

  end

  def find

    #amount, offset, lat_min, lon_min, lat_max, lon_max, price, start, end, [tags]
    params[:amount] = params[:amount] || 10
    params[:offset] = params[:offset] || 0

    # @events = Event.search params[:search]
    @events = Event.all

    # find occurrences that start between params[:start] and params[:end] and are on params[:day] day of the week 
    if(params[:start] || params[:end] || params[:day])

      event_start = DateTime.parse(params[:start] || "1900-01-01").to_s
      event_end = DateTime.parse(params[:end] || "9999-12-31").to_s

      event_days = params[:day].split(',')
      
      @occurrences = Occurrence.where("start >= ? AND start <= ? AND day_of_week IN (?)", event_start, event_end, event_days)
      
      # puts @occurrences
      # get events of those occurrences
      @events = @events & @occurrences.collect{ |o| o.event }
    end

    #filter by location
    if(params[:lat_min] && params[:long_min] && params[:lat_max] && params[:long_max])
      @events.select! {|e| ((params[:lat_min].to_f)..(params[:lat_max].to_f)).include?(e.venue.latitude) && ((params[:long_min].to_f)..(params[:long_max].to_f)).include?(e.venue.longitude) }
    end
    
    # filter by tags
    if(params[:tags])
      @tagIDs = params[:tags].split(",").collect { |str| str.to_i }
      
      @events.each { |e| puts e.tags.collect { |tag| tag.id} }
      @events.select! { |e| !((e.tags.collect { |tag| tag.id } & @tagIDs).empty?) }
    end

    @priceRanges = [0,0.01,10,25,50]

    #filter by price
    if(params[:price])
      @prices = params[:price].split(",").collect { |str| str.to_i }
      @events.select! do |e|
        if e.price.nil?
          false
        else
          @prices.reduce(false) { |aggregate, i| aggregate || (@priceRanges[i] <= e.price &&
                                                             ((i == @priceRanges.length - 1) ? true : @priceRanges[i+1] > e.price)) }
        end
      end
    end

    # filter by offset and amount

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events.to_json(:include => [:occurrences, :venue]) }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event.to_json(:include => [:occurrences, :venue]) }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    #@venues = Venue.all
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    #@venues = Venue.all
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @occurrence = Occurrence.new(:start => params[:start], :end => params[:end], :event_id => @event.id)
    puts params[:start]
    puts params[:end]
    respond_to do |format|
      if @event.save && @occurrence.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end
end
