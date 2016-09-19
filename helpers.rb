module Helpers
  def email_link_from_response(response)
    email = response.body['primary_email']
    email ? "<a href='mailto:#{email}'>#{email}</a>" : 'N/A'
  end

  def last_activity_from_response(response)
    last = response.body.collect{ |t| t['created_at'] }.reject(&:nil?).sort.last
    last ? Time.parse(last).strftime("%B %d, %Y") : 'N/A'
  end

  def profile_link(user_id, user_name)
    "<a href='#{settings.canvas_url}/users/#{user_id}' target='_blank'>"\
      "#{user_name}"\
    "</a>"
  end
end
