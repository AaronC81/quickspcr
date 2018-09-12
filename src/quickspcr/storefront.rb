require 'http'
require 'json'

# Provides methods to interact with the Steam Storefront API to get app
# information.
class Storefront
  # Returns a hash of app information given an app ID.
  def self.app_info(app_id)
    url = "https://store.steampowered.com/api/appdetails?appids=#{app_id}"
    result = Http.get(url)
    JSON.parse(result.to_s)[app_id.to_s]
  end
end