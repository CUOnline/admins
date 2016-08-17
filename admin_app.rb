require 'bundler/setup'
require 'wolf_core'
require 'wolf_core/auth'

class AdminApp < WolfCore::App
  set :root, File.dirname(__FILE__)
  set :views, ["#{root}/views", settings.base_views]
  set :allowed_roles, ["AccountAdmin", "Help Desk"]

  get '/' do
    @schools = canvas_api(:get, "accounts/#{settings.canvas_account_id}/" \
                                "sub_accounts?per_page=50")
    slim :index
  end

  get '/admins/:school_id' do
    @admins = canvas_api(:get, "accounts/#{params['school_id']}/admins")
    slim :_admins, :layout => false
  end

  get '/user/:user_id' do
    profile = canvas_api(:get, "/users/#{params['user_id']}/profile")
    @email = profile['primary_email'] || 'N/A'

    timestamps = canvas_api(:get, "/users/#{params['user_id']}/page_views")
    last = timestamps.collect{ |t| t['created_at'] }.reject(&:nil?).sort.last
    @last_activity = last ? Time.parse(last).strftime("%B %d, %Y") : 'N/A'

    slim :_user, :layout => false
  end
end
