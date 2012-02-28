#!/usr/bin/env ruby

require 'rubygems'
require 'oauth'
require 'json'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

consumer_key = ['aqTYq-SdJmSZ1B0NyXjzzA', '137XY7xWDA5qz8OMTwK5pA', 'svSOsEvroLTJi4t92CwAJg', '70d582msf8_EV_tX8B61WQ', 'mQ_igvlsg_d_dM_l9zQMSw', 'myTXopPweahEmgqmvAWOCg', 'AmSpf-A7evVDpBezvDQgbQ', 'im9-qVU_a2-xpse2aonFHw', 'hMQmr_HHL_-LczSK4f_3OQ', 'b4yNqMwPygvZ13PUkdilUw']
consumer_secret = ['m3M-0Da_-7SYIPzsolknVAZKfkQ', 'vm1Rugb-EL1tTJwz33e2LelvnoQ', 'Oe6QNeHafv38PO269zFedKw7bWI', 'KckA0i3JcgSNmooj1emCFCc4txc', 'I6_k_C3NpSEQLE7fJcROKOMHPek', 'TF5lAnNeNVgehpH4KQk1WuwMzjc', 'P9yYLfHOp8gsHfeCNquF1zbW9Pc', 'DXXVcXsv9fwANJLKYX-EEuqugXg', '1tGQy9KwrkWjLcI6N06-1Fcb-8Y', '5hwi0RddscA7i3DH1bsz85NgIFE']
token = ['I0G6mUNTUmg9jT9gLXsiVesvF8d6lzT0', 'zHKDwi6dKugp9x8PKDd1Sv8oXd_V0-WK', 'LX3yPczDWvI_4z-qyd1HrI1EZkHga2ri', 'mf6C-gNZ-31n9uave79bNNQeb61jCnLg', 'Yp7mZXir14JXYDdI1H54xKDFDxuV5L3c', 'W0pBfvP7wQu-gf_Ak5WsQrCVDJMiYMl_', 'ZqBBUWzGpQoTLNltvm3g-CvghJMS1mJT', 'WFXfmf0Kk2G6wJwXPsfpusBpHCEmepER', 'hWHiLF5pwTkXaX7ahCsPzoZpn2vLwOlw', 'ryCV0Nhz2zqeO8YaAHt5Y9e32ty_Zd5G']
token_secret = ['VlKMTKORIG_dq6wmNdkkMKOlieA', 'O0UTL32qkKGz8VyHnATadV2A3is', 'VWJZH54DigHhXkOBJjbPyjUlGbU', 'PxVzwUMTV67Im-NVklKWeT6TJiE', 'YL5oIsSLiRdGNJUlV47K76iSii0', '6A5rWNDBRiZrCbZ3VrMCXz6mb_s', 'LQ3xmYo0Dn3QBqCH4488rUhIn08', 'ilo57jSnYGdtKITfe9miQwDzdDE', 'C-1Sx56SOKhttmI9aTVbhOhR2Bo', 'nLulbwI5Wfr5rQK5PUYj0lcnytM']

api_host = 'api.yelp.com'

consumer = OAuth::Consumer.new(consumer_key[0], consumer_secret[0], {:site => "http://#{api_host}"})
access_token = OAuth::AccessToken.new(consumer, token[0], token_secret[0])

latitude = 30.16
latitude_max = 30.48
latitude_delta = 0.00005
longitude_min = -97.85
longitude_max = -97.65


while latitude < latitude_max
  offset = (RawVenue.all == nil) ? "0" : RawVenue.all.count.to_s
  path = "/v2/search?category_filter=active,arts,beautysvc,education,eventservices,food,hotelstravel,localflavor,localservices,nightlife,publicservicesgovt,religiousorgs,restaurants,shopping&bounds=" + latitude.to_s + "," + longitude_min.to_s + "%7C" + (latitude + latitude_delta).to_s + "," + longitude_max.to_s +  "&sort=0&limit=20"
  
  p path
  
  venues = JSON.parse(access_token.get(path).body)
  
  if venues["businesses"] == nil
    p venues.inspect
    break
  else
    latitude += latitude_delta
    p "latitude: " + latitude.to_s 
    venues["businesses"].each do |venue|
      if RawVenue.first(:conditions => { :name2 => venue["id"] }) != nil
	p venue["name"] + " is a dupe"
      else 
	newVenue = RawVenue.new( :name => venue["name"],
			      :name2 => venue["id"],
			      :address => venue["location"]["address"][0],
			      :address2 => venue["location"]["address"][1],
			      :zip => venue["location"]["postal_code"],
			      :city => venue["location"]["city"],
			      :state_code => venue["location"]["state_code"],
			      :phone => venue["display_phone"],
			      :latitude => venue["location"]["coordinate"]["latitude"],
			      :longitude => venue["location"]["coordinate"]["longitude"],
			      :rating => venue["rating"],
			      :review_count => venue["review_count"] )
	unless venue["categories"] == nil || venue["categories"].count == 0
	  newVenue["categories"] = ""
	  venue["categories"].each_with_index do |category, i|
	    newVenue["categories"] += category[0]
	    unless i == venue["categories"].count - 1
	      newVenue["categories"] += "||"
	    end
	  end
	end
	unless venue["location"]["neighborhoods"] == nil || venue["location"]["neighborhoods"].count == 0
	  newVenue["neighborhoods"] = ""
	  venue["location"]["neighborhoods"].each_with_index do |neighborhood, i|
	    newVenue["neighborhoods"] += neighborhood
	    unless i == venue["location"]["neighborhoods"].count - 1
	      newVenue["neighborhoods"] += "||"
	    end
	  end
	end
	unless newVenue.save
	  p newVenue["name"] + " save failed"
	end
      end
    end
  end
end