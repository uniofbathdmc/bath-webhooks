require 'json'
require 'slack-notifier'
require 'github_webhook_service'

class WebhookController < ApplicationController
  # prefers application/json
  def bamboo
    puts 'processing incoming bamboo payload'
    json = params[:payload]
    data = JSON.parse(CGI.unescape(json))
    puts 'data has been parsed'

    msg = create_bamboo_message(data)
    notify_slack('', msg)
    puts 'all done'

    update_build_infos(msg[:title], msg[:color])

    head :ok
  end

  def create_bamboo_message(data)
    if data['attachments'][0]['color'] == '#ff0000'
      colour = 'danger'
    elsif data['attachments'][0]['color'] == '#00ff00'
      colour = 'good'
    else
      colour = 'warning'
    end

    text = data['attachments'][0]['fallback'].gsub(/\. See details\./, '')

    {
      title: text,
      fallback: text,
      color: colour
    }
  end

  def update_build_infos(text, colour)
    build_info = BuildInfo.new
    build_info.display = text
    build_info.time = DateTime.now
    build_info.colour = colour

    build_info.save
  end

  # expects application/json
  def pivotal
    message = params[:message]
    slackbot_shipit_notification if message.include?('accepted this')
    head :ok
  end

  def slackbot_shipit_notification
    notify_slack('Time to ship to production!')
  end

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
end
