require 'bundler/setup'
require 'wolf_core'

require_relative './helpers.rb'

class AdminApp < WolfCore::App
  set :title, 'Canvas Admin Directory'
  set :root, File.dirname(__FILE__)
  set :allowed_roles, ["AccountAdmin", "Help Desk"]
  set :auth_paths, [/.*/]

  helpers Helpers

  get '/' do
    url = "accounts/#{settings.canvas_account_id}/sub_accounts?per_page=100"
    @schools = canvas_api.get(url).body
    slim :index
  end

  get '/admins/:school_id' do
    @admins = canvas_api.get("accounts/#{params['school_id']}/admins").body

      api = canvas_api
      api.in_parallel do
        @admins.each do |a|
        admin_id = a['user']['id']
        # Just store the API response object for now. Use helpers to parse for
        # real values later. Can't do it here as the responses are nil for the
        # duration of this block when requests are made in parallel
        a['user']['email'] = api.get("users/#{admin_id}/profile")
        a['user']['last_activity'] = api.get("users/#{admin_id}/page_views")
      end
    end

    slim :_admins, :layout => false
  end
end
