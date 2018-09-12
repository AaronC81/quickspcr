require_relative 'spcr'
require 'shellwords'

# Handles displaying a prompt and launching the browser if necessary.
class Prompt
  def self.show(app_id, app_name)
    message = %W[
      Looks like you've been playing #{app_name}. Would you like to
      compose a report for it on SPCR?
    ].join(' ')

    system(%W[
      zenity --question --width 600 --title QuickSPCR
      --text "#{Shellwords.escape(message)}"
    ].join(' '))

    return unless $?.exitstatus.zero?

    Spcr.open_contribution_page(app_id)
  end
end
