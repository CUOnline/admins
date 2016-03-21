class AdminApp < Wolf::Base
  set :root, File.dirname(__FILE__)
  self.setup

  use Wolf::AuthFilter

  get '/' do
    url = "#{settings.api_base}/accounts/" \
          "#{settings.canvas_account_id}" \
          "/sub_accounts?per_page=50"

    response = RestClient.get(url, auth_header)
    @schools = JSON.parse(response.body)

    slim :index
  end

  get '/admins/:school_id' do
    url = "#{settings.api_base}/accounts/#{params['school_id']}/admins"
    response = RestClient.get(url, auth_header)
    @admins = JSON.parse(response)

    slim :_admins, :layout => false
  end

  get '/user/:user_id' do
    url = "#{settings.api_base}/users/#{params['user_id']}/profile"
    response = RestClient.get(url, auth_header)
    @email = JSON.parse(response)['primary_email'] || 'N/A'

    url = "#{settings.api_base}/users/#{params['user_id']}/page_views"
    response = RestClient.get(url, auth_header)
    timestamps = JSON.parse(response).collect{ |t| t['created_at'] }
    last = timestamps.reject(&:nil?).sort.last
    @last_activity = last ? Time.parse(last).strftime("%B %d, %Y") : 'N/A'

    slim :_user, :layout => false
  end
end
