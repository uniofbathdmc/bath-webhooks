# Methods for processing posts from Bamboo
module Bambooable
  extend ActiveSupport::Concern

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

  # at the moment this object is tailored for use with Bamboo notifications
  def update_build_infos(text, colour)
    build_info = BuildInfo.new
    build_info.display = text
    build_info.time = DateTime.now
    build_info.colour = colour

    build_info.save
  end
end
