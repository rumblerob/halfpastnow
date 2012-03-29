class VenuesController < ApplicationController
  # GET /venues
  # GET /venues.json
  def index
    # @venues = Venue.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venues }
    end
  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    @venue = Venue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue.to_json(:include => { :events => { :include => :occurrences } } ) }
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
  end

  # POST /venues
  # POST /venues.json
  def create
    @venue = Venue.new(params[:venue])

    respond_to do |format|
      if @venue.save
        format.html { redirect_to action: :index }
        format.json { render json: @venue, status: :created, location: @venue }
      else
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
          puts "recurring"
          params_event[1]["occurrences_attributes"].shift
          if params_event[1]["occurrences_attributes"].length == 0
            params_event[1].delete("occurrences_attributes")
          end
        else
          puts "not recurring"
          params_event[1]["recurrences_attributes"].shift
          if params_event[1]["recurrences_attributes"].length == 0
            params_event[1].delete("recurrences_attributes")
          end
        end
        if params_event[1]["occurrences_attributes"] 
          params_event[1]["occurrences_attributes"].each_with_index do |params_occurrence, index|
            puts "start(4i): " + params_occurrence[1]["start(4i)"]
            if params_occurrence[1]["start(4i)"] == "" || params_occurrence[1]["start(5i)"] == "" || params_occurrence[1]["end(4i)"] == "" || params_occurrence[1]["end(5i)"] == ""  
              puts "deleting occurrence:"
              puts index
              puts params_event[1]["occurrences_attributes"][index.to_s]
              params_event[1]["occurrences_attributes"].delete(index.to_s)
            end
          end
        end
        if params_event[1]["recurrences_attributes"]
          params_event[1]["recurrences_attributes"].each do |params_recurrence|
            puts "start(4i): " + params_recurrence[1]["start(4i)"]
            if params_recurrence[1]["start(4i)"] == "" || params_recurrence[1]["start(5i)"] == "" || params_recurrence[1]["end(4i)"] == "" || params_recurrence[1]["end(5i)"] == ""  
              puts "deleting recurrence"
              params_recurrence.shift(2)
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
