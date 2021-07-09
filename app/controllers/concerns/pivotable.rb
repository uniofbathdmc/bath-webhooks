# Methods for processing posts from Pivotal
module Pivotable
  extend ActiveSupport::Concern

  # expects application/json
  def pivotal
    message = params[:message]
    slackbot_shipit_notification if message.include?('accepted this')
    head :ok
  end

  def slackbot_shipit_notification
    notify_slack('Time to ship to production!')
  end
end