require "net/http"
require "json"

class Geolocation
  attr_reader :ip

  def initialize(ip)
    @ip = ip
    @data = get_location
    @data = default_location if city.empty?
  end

  def city
    @data["city"]
  end

  def state
    @data["region_name"]
  end

  def country
    @data["country_name"]
  end

  def zip
    @data["zip_code"]
  end

  private
  def get_location
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end

  def uri
    URI("http://freegeoip.net/json/#{@ip}")
  end

  def default_location
    {
      "ip" => @ip,
      "country_code" => "US",
      "country_name" => "United States",
      "region_code" => "MA",
      "region_name" => "Massachusetts",
      "city" => "Boston",
      "zip_code" => "02124",
      "time_zone" => "America/New_York",
      "latitude" => 42.2848,
      "longitude" => -71.0741,
      "metro_code" => 506
    }
  end
end
