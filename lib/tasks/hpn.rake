require 'net/http'
require 'rexml/document'
require 'pp'
include REXML

desc "discard old occurrences and create new ones from recurrences"
task :update_occurrences => :environment do
	puts "update_occurrences"
	old_occurrences = Occurrence.where(:start => (DateTime.new(1900))..(DateTime.now))
	old_occurrences.each do |occurrence|
		puts "occurrence id: " + occurrence.id.to_s
		#if occurrence doesn't have a recurrence, then just destroy it
		#otherwise, try to generate more occurrences from the recurrence.
			#if it can't, and the occurrence is the only occurrence of the recurrence, then destroy the recurrence
		if occurrence.recurrence.nil?
			occurrence.destroy
			# TODO: delete the event
		else
			if (!occurrence.recurrence.gen_occurrences(1) && occurrence.recurrence.occurrences.count == 1)
				occurrence.recurrence.destroy
			else
				occurrence.destroy
			end
		end
	end
end

desc "generate venues from raw_venues"
task :raw_venues_to_venues => :environment do
	raw_venues = RawVenue.all
	raw_venues.each do |raw_venue| 
		Venue.create({
			:name => raw_venue.name,
			:address => raw_venue.address,
			:address2 => raw_venue.address2,
			:city => raw_venue.city,
			:state => raw_venue.state_code,
			:zip => raw_venue.zip,
			:latitude => raw_venue.latitude,
			:longitude => raw_venue.longitude,
			:phonenumber => raw_venue.phone
		})
	end
end
 
desc "pull events from assorted apis"
task :pull_api_events, [:until_time]  => :environment do |t, args|
	d_until = args[:until_time] ? DateTime.parse(args[:until_time]) : nil

	page = 0
	begin
		@breakout = false
		apiURL = URI("http://events.austin360.com/search?rss=1&sort=1&srss=100&city=Austin&ssi=" + (page*100).to_s)
		apiXML = Net::HTTP.get(apiURL)
		doc = Document.new(apiXML)
		stream_count = XPath.first( doc, "//stream_count").text
		if stream_count == 0
			break
		end
		XPath.each( doc, "//item") do |item|
			from = item.elements["title"].text.index("Event:") + 7
			to = item.elements["title"].text.rindex(" at ") - 1
			d_start = item.elements["xCal:dtstart"].text ? DateTime.parse(item.elements["xCal:dtstart"].text) : nil
			d_end = item.elements["xCal:dtend"].text ? DateTime.parse(item.elements["xCal:dtend"].text) : nil

			if(d_until && d_start && d_start > d_until)
				@breakout = true
				break
			elsif RawEvent.where(:raw_id => item.elements["id"].text).count > 0
				next
			end

			raw_event = RawEvent.create({
				:title => item.elements["title"].text[from..to],
			    :description => item.elements["description"].text,
			    :start => d_start,
			    :end => d_end,
			    :latitude => item.elements["geo:lat"].text,
			    :longitude => item.elements["geo:long"].text,
			    :venue_name => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-venue-name"].text,
			    :venue_address => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-street"].text,
			    :venue_city => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-city"].text,
			    :venue_state => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-region"].text,
			    :venue_zip => item.elements["xCal:x-calconnect-venue"].elements["xCal:adr"].elements["xCal:x-calconnect-postalcode"].text,
			    :url => item.elements["link"].text,
			    :raw_id => item.elements["id"].text,
			    :from => "austin360"
			})
		end
		page += 1
	end until @breakout
end