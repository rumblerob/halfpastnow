require 'pp'
require 'open-uri'
require 'json'

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

def index

    @amount = params[:amount] || 20
    @offset = params[:offset] || 0

    # @events = Event.search params[:search]
    @events = Event.all.select { |event| event.occurrences.length > 0 }

    if (params[:search] && params[:search] != "")
      @events.select! { |event| event.matches? params[:search] }
    end

    # TODO: cache earliest occurrence for each event so we don't have to do this
    # find occurrences that start between params[:start] and params[:end] and are on params[:day] day of the week 
    #if(params[:start] || params[:end] || params[:day])

      event_start = (params[:start] ? Time.at(params[:start].to_i).to_datetime.to_s : DateTime.now.to_s)
      event_end = Time.at(params[:end] ? params[:end].to_i : 32513174400).to_datetime.to_s

      event_days = params[:day] ? params[:day].split(",") : nil
      
      if event_days
        @occurrences = Occurrence.where("start >= ? AND start <= ? AND day_of_week IN (?)", event_start, event_end, event_days)
      else
        @occurrences = Occurrence.where("start >= ? AND start <= ?", event_start, event_end)
      end

      @occurrences.sort_by! { |o| o.start }
      # puts @occurrences
      # get events of those occurrences
      @events = @occurrences.collect{ |o| o.event } & @events
    #end

    #filter by location
    # either lat/long OR (location or nothin')
    if(params[:lat_min] && params[:long_min] && params[:lat_max] && params[:long_max])
      @lat_min = params[:lat_min]
      @lat_max = params[:lat_max]
      @long_min = params[:long_min]
      @long_max = params[:long_max]
    else
      @ZoomDelta = {
               11 => { :lat => 0.30250564 / 2, :long => 0.20942688 / 2 }, 
               13 => { :lat => 0.0756264644 / 2, :long => 0.05235672 / 2 }, 
               14 => {:lat => 0.037808182 / 2, :long => 0.02617836 / 2 }
              }

      @lat = 30.25
      @long = -97.75
      @zoom = 11

      if params[:location] && params[:location] != ""
        json_object = JSON.parse(open("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + URI::encode(params[:location])).read)
        unless (json_object.nil? || json_object["results"].length == 0)

          @lat = json_object["results"][0]["geometry"]["location"]["lat"]
          @long = json_object["results"][0]["geometry"]["location"]["lng"]
          # if the results are of a city, keep it zoomed out aways
          if (json_object["results"][0]["address_components"][0]["types"].index("locality").nil?)
            @zoom = 14
          end
        end
      end

      @lat_delta = @ZoomDelta[@zoom][:lat]
      @long_delta = @ZoomDelta[@zoom][:long]
      @lat_min = @lat - @lat_delta
      @lat_max = @lat + @lat_delta
      @long_min = @long - @long_delta
      @long_max = @long + @long_delta
    end
    
    @events.select! {|e| ((@lat_min.to_f)..(@lat_max.to_f)).include?(e.venue.latitude) && ((@long_min.to_f)..(@long_max.to_f)).include?(e.venue.longitude) }
    
    # filter by tags
    if(params[:tags])
      @tagIDs = params[:tags].split(",").collect { |str| str.to_i }
      
      # @events.each { |e| puts e.tags.collect { |tag| tag.id} }
      @events.select! { |e| (e.tags.collect { |tag| tag.id } & @tagIDs).size == @tagIDs.size }
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

    if(params[:sort].nil? || params[:sort] == "" || params[:sort] == 0)
      @events = @events.sort_by do |event| 
        event.score
      end.reverse
    end

    # @events = @events.drop(@offset).take(@amount)

    @events.each do |event| 
      event.views += 1 
      event.venue.views += 1
      event.save
      event.venue.save
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events.to_json(:include => [:occurrences, :venue]) }
    end

  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    @event.clicks += 1
    @event.save

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
