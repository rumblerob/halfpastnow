require 'pp'

class VenuesController < ApplicationController
  # GET /venues
  # GET /venues.json
  def index
    # @venues = Venue.all
    @venues = RawEvent.where(:submitted => nil, :deleted => nil).collect { |raw_event| raw_event.raw_venue ? raw_event.raw_venue.venue : nil }.compact
    @num_raw_events = Hash.new(0)
    @venues.each { |venue| @num_raw_events[venue.id] += 1 }
    @venues.uniq!
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venues }
    end
  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    @venue = Venue.find(params[:id])
    puts "venue_id in show venues_controller :"
    puts  params[:id]
    
    @venue_events = @venue.events
    
    #@venue.phonenumber = RawVenue.find_by_name(@venue.name).phone
    #@venue.url = RawVenue.find_by_name(@venue.name).url
    puts @venue.to_json(:include => { :events => { :include => :occurrences }} )

    @venue.clicks += 1
    @venue.save
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue.to_json(:include => { :events => { :include => :occurrences }} ) }
    end
  end

  # GET /venues/find
  def find
    if(params[:contains])
      @venues = Venue.where("name ilike ?", "%#{params[:contains]}%").collect {|v| { :label => "#{v.name} (#{v.address})", :value => "#{v.name} (#{v.address})", :id => v.id } }
    else
      @venues = []
    end

    render json: @venues
  end

  # GET /venues/new
  # GET /venues/new.json
  def new
    @venue = Venue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @venue }
    end
  end

  # GET /venues/edit/1
  def edit
    @venue = Venue.find(params[:id])
    @venue.events.build
    @venue.events.each do |event| 
      event.occurrences.build(:start => Date.today.to_datetime, :end => Date.today.to_datetime)
      event.recurrences.build
    end

    @parentTags = Tag.all(:conditions => {:parent_tag_id => nil})
  end

  # POST /venues
  # POST /venues.json
  def create
    @venue = Venue.new(params[:venue])

    respond_to do |format|
      if @venue.save
        puts "here save"
        format.html { redirect_to action: :index }
        format.json { render json: @venue, status: :created, location: @venue }
      else
        puts "here not save"
        format.html { render action: "new" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update
    @venue = Venue.find(params[:id])

    if(params[:venue][:events_attributes])
      params[:venue][:events_attributes].each do |params_event|
        if params_event[1]["recurring"]
          # puts "recurring"
          params_event[1]["occurrences_attributes"].shift
          if params_event[1]["occurrences_attributes"].length == 0
            params_event[1].delete("occurrences_attributes")
          end
        else
          # puts "not recurring"
          params_event[1]["recurrences_attributes"].shift
          if params_event[1]["recurrences_attributes"].length == 0
            params_event[1].delete("recurrences_attributes")
          end
        end
        if params_event[1]["occurrences_attributes"]
          params_event[1]["occurrences_attributes"].each_with_index do |params_occurrence, index|
            # puts "start(4i): " + params_occurrence[1]["start(4i)"]
            if params_occurrence[1]["start(4i)"] == "" || params_occurrence[1]["start(5i)"] == ""
              # puts "deleting occurrence:"
              # puts index
              # puts params_event[1]["occurrences_attributes"][index.to_s]
              params_event[1]["occurrences_attributes"].delete(index.to_s)
            else
              # params_occurrence[1]["day_of_week"] = Date.parse(params_occurrence[1]["start(1i)"] + "-" + params_occurrence[1]["start(2i)"] + "-" + params_occurrence[1]["start(3i)"]).wday
            end
          end
        end
        if params_event[1]["recurrences_attributes"]
          params_event[1]["recurrences_attributes"].each do |params_recurrence|
            # puts "start(4i): " + params_recurrence[1]["start(4i)"]
            if params_recurrence[1]["start(4i)"] == "" || params_recurrence[1]["start(5i)"] == ""  
              # puts "deleting recurrence"
              params_recurrence.shift(2)
            else
              # params_recurrence[1]["day_of_week"] = Date.parse(params_recurrence[1]["start(1i)"] + "-" + params_recurrence[1]["start(2i)"] + "-" + params_recurrence[1]["start(3i)"]).wday
            end
          end
        end
        params_event[1].delete("recurring")
      end
    end

    puts params[:venue]

    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        format.html { redirect_to :action => :edit, :id => @venue.id, :notice => 'yay' }
        format.json { head :ok }
      else
        format.html { redirect_to :action => :edit, :id => @venue.id, :notice => 'boo' }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /venues/new
  # GET /venues/new.json
  def fromRaw
    @venue = Venue.find(params[:id])
    puts params
    @event = @venue.events.build()
    @event.update_attributes(params[:event])
    # pp @event
    @raw_event = RawEvent.find(params[:raw_event_id])
    @raw_event.submitted = true
    #pp @raw_event
    @raw_event.save
    @event.save

    redirect_to :action => :edit, :id => @venue.id
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to venues_url }
      format.json { head :ok }
    end
  end
end
