require 'json'
require 'slack-notifier'

class WebhookController < ApplicationController
  include Bambooable
  include Pivotable

  # the concerns are using this method to talk to Slack
  def notify_slack(message, data = '')
    unless ENV['SLACK_WEBHOOK_ENDPOINT'].blank?
      notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_ENDPOINT'])
      notifier.ping(message, attachments: [data])
    end
  end
end
