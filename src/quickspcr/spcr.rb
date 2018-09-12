# Contains methods for opening SPCR.
class Spcr
  # Opens an SPCR contribution page for the given app ID.
  def self.open_contribution_page(app_id)
    `xdg-open https://spcr.netlify.com/contribute?appId=#{app_id}`
  end
end