require 'json'
require 'slack-notifier'
require 'github_webhook_service'
require 'gitlab_webhook_service'

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

  # expects POST application/json
  def github
    GithubWebhookService.handle_payload(JSON.parse(request.body.read))
    head :ok
  end

  # expects POST application/json
  def gitlab
    GitlabWebhookService.handle_payload(JSON.parse(request.body.read))
    head :ok
  end
end
