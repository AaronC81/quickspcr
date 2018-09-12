require 'steam_codec'
require 'filewatcher'

# Reads various Steam files to discover local game information.
class Steam
  STEAM_HOME = File.expand_path("~/.steam")
  STEAM_REGISTRY = "#{STEAM_HOME}/registry.vdf"
  STEAM_CONFIG = "#{STEAM_HOME}/steam/config/config.vdf"
  STEAM_PRIMARY_LIBRARY_FOLDER = "#{STEAM_HOME}/steam/steamapps"
  STEAM_LIBRARY_FOLDERS = "#{STEAM_PRIMARY_LIBRARY_FOLDER}/libraryfolders.vdf"

  # Opens a VDF and returns an insensitive hash of its contents.
  # @param [String] path The path to the VDF.
  # @return [SteamCodec::KeyValues]
  def self.read_vdf(path)
    contents = File.read(path).to_s
    SteamCodec::VDF.load(contents)
  end

  # Given a VDF object, gets its numeric keys, sorts them, and returns their
  # values as an array.
  # @param [SteamCodec::KeyValues] vdf The VDF object.
  # @return [Array<SteamCodec::KeyValues>]
  def self.vdf_array_items(vdf)
    vdf.select { |k, _| /\d+/.match?(k) }
       .sort_by { |k, _| k.to_i }
       .map { |_, v| v }
  end

  # Gets the Proton version.
  def self.proton_version
    friendly_names = {
      'proton_37' => 'Proton 3.7',
      'proton_37_beta' => 'Proton 3.7 Beta'
    }
    config = read_vdf(STEAM_CONFIG)
    proton_version = config.InstallConfigStore.Software.Valve.Steam
                           .ToolMapping["0"].name
    friendly_names[proton_version] || proton_version
  end

  # Gets the statuses of apps available to this account, in the form of an
  # insensitive hash indexed by app ID. The keys are another hash with keys
  # "installed", "Updating" and "Running" (note the casing), each with a
  # value of either "0" or "1".
  # @return [SteamCodec::KeyValues]
  def self.app_statuses
    read_vdf(STEAM_REGISTRY).Registry.HKCU.Software.Valve.Steam.apps
  end

  # Gets the app IDs of any running apps.
  # @return [Array<Integer>]
  def self.running_app_ids
    app_statuses.select { |_, v| v.installed == '1' && v.Running == '1' }.map { |k, _| k }
  end

  # Gets an array of Steam library folder paths.
  # @return [Array<String>]
  def self.steam_library_folders
    vdf_folders = vdf_array_items(read_vdf(STEAM_LIBRARY_FOLDERS).LibraryFolders)
    [STEAM_PRIMARY_LIBRARY_FOLDER] + vdf_folders.map { |x| "#{x}/steamapps" }
  end

  # Finds the installation folder of a Steam game by its app ID.
  # TODO: Unused and untested. Remove?
  def self.installation_directory(app_id)
    # Go through each library folder and look for a manifest
    steam_library_folders.each do |library|
      manifest_path = "#{library}/appmanifest_#{app_id}.acf"
      next unless File.exist?(manifest_path)
      acf = SteamCodec::ACF.loadFromFile(manifest_path)
      return "#{library}/common/#{acf.InstallDir}"
    end
  end

  # Starts a registry file listener, invoking `on_start` when an app starts and
  # `on_stop` when one stops. Both methods are passed the relevant ID.
  def self.listen_for_app_changes(on_start, on_stop)
    prev_running = []
    Filewatcher.new(STEAM_HOME).watch do |*|
      current_running = running_app_ids

      # Look for any started IDs
      current_running.each { |id| on_start.(id) unless prev_running.include? id }

      # Look for any closed IDs
      prev_running.each { |id| on_stop.(id) unless current_running.include? id }

      prev_running = current_running
    end.start
  end
end