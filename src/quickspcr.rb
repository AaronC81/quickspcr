require_relative 'quickspcr/steam'
require_relative 'quickspcr/spcr'
require_relative 'quickspcr/storefront'
require_relative 'quickspcr/prompt'

def on_stop(app_id)
  puts "stopped #{app_id}"
  app_info = Storefront.app_info(app_id)
  app_name = app_info['data']['name']
  supported_natively = app_info['data']['platforms']['linux']

  return if supported_natively

  Prompt.show(app_id, app_name)
end

app = Prompt.new

Steam.listen_for_app_changes(->(*) {}, method(:on_stop))
