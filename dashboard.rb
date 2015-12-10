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

    event = Event.new(@city,@state)
    @current_event = event.current


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

    return "#{hourly_temps["current_observation"]["temp_f"]}"
  end
end



class Event
  def initialize(city, state)
    @city = city
    @state = state
  end

  def current

    key_1 = ENV["NYTIMES_API_KEY"]
    uri = URI("http://api.nytimes.com/svc/events/v2/listings.json?query=#{@state}+and+#{@city}&api-key=#{key_1}")
    response = Net::HTTP.get_response(uri)
    event = JSON.parse(response.body)

    return event
  end
end
