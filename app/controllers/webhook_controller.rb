require 'json'
require 'slack-notifier'

class WebhookController < ApplicationController

  # prefers application/json
  def bamboo
    puts 'processing incoming bamboo payload'
    json = params[:payload]
    puts 'json: ' + json
    data = JSON.parse(CGI::unescape(json))
    puts 'data has been parsed'
    notify_slack('', create_bamboo_message(data))
    puts 'all done'
    head :ok
  end

  # expects application/json
  def pivotal
    message = params[:message]
    if message.include('accepted this')
      slackbot_shipit_notification
    end
    head :ok
  end

  def notify_slack(message, data)
    puts 'in notify slack'
    notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_ENDPOINT'])
    notifier.ping message, attachments: (data)
  end

  def create_message(data)
    puts 'in create_message'
    puts JSON.pretty_generate(data)
    puts data['attachments'][0]['color']
    if data['attachments'][0]['color'] == '#ff0000'
      colour = 'danger'
    elsif data['attachments'][0]['color'] == '#00ff00'
      colour = 'good'
    else
      colour = 'warning'
    end

    title = data['attachments'][0]['fallback']
    # title_link = 'http://www.google.com'

    {
      title: title,
      # title_link: title_link,
      fallback: title,
      color: colour
    }
  end

  def slackbot_shipit_notification
    notify_slack(':shipit:')
  end

end
