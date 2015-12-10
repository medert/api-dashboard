require "./lib/geolocation"
require "sinatra/base"
require "json"
require "net/http"
require 'pry'

require "dotenv"
Dotenv.load

class Dashboard < Sinatra::Base
  get("/") do
    @ip = request.ip
    @geolocation = Geolocation.new(@ip)
    @city = @geolocation.city
    @state = @geolocation.state

    # current temperature
    temp = Temp.new(@city,@state)
    @current_temp = temp.current

    events = Event.new(@city,@state)
    @current_events = events.current

    headlines = Headlines.new(@city,@state)
    @current_headlines = headlines.current

    erb :dashboard
  end
end

class Temp
  def initialize(city, state)
    @city = city
    @state = state
  end

  def current

    key = ENV["WUNDERGROUND_API_KEY"]
    uri = URI("http://api.wunderground.com/api/#{key}/conditions/q/#{@state}/#{@city}.json")
    response = Net::HTTP.get_response(uri)
    hourly_temps = JSON.parse(response.body)

    local_temp = "#{hourly_temps["current_observation"]["temp_f"]}"
    return local_temp
  end
end

class Event
  def initialize(city, state)
    @city = city
    @state = state
  end

  def current

    uri = URI("http://api.seatgeek.com/2/events?venue.city=#{@city}")
    response = Net::HTTP.get_response(uri)
    events = JSON.parse(response.body)["events"]

    events_list = []

    events.each do |event|
      events_list << "#{event["title"]} @ #{event["venue"]["name"]}"
    end

    return events_list

  end
end

class Headlines
  def initialize(city, state)
    @city = city
    @state = state
  end

  def current
    ny_times_key = ENV["NYTIMES_API_KEY"]
    uri =  URI("http://api.nytimes.com/svc/topstories/v1/technology.json?api-key=#{ny_times_key}")

    response = Net::HTTP.get_response(uri)
    headlines = JSON.parse(response.body)

    headlines_hash = Hash.new()

    headlines.each do |headline|
     headlines["results"].each do |item|
        title = item["title"]
        url = item["url"]
        headlines_hash[title] = url
     end
    end

    return headlines_hash
  end
end
