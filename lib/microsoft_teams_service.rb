require 'net/http'

module MicrosoftTeamsService
  TEAMS_WEBHOOK_URL = ENV['TEAMS_WEBHOOK_URL']
  TEAMS_HEADER = { 'Content-Type' => 'application/json' }.freeze

  def self.send_reviewed_card(review_data, stories: [])
    sections = [gitlab_section(review_data)]
    sections += stories.map { |story_id| pivotal_section(story_id) }
    send_card(
      summary: 'Merge Request reviewed',
      title: review_data[:gitlab_project_path],
      sections: sections
    )
  end

  def self.gitlab_section(review_data)
    {
      activityImage: review_data[:gitlab_user_avatar_url],
      activityTitle: "Merge Request [!#{review_data[:gitlab_mr_number]}](#{review_data[:gitlab_mr_url]}) reviewed OK by #{review_data[:gitlab_user_name]} (#{review_data[:gitlab_user]})",
      activitySubtitle: "in [#{review_data[:gitlab_project_path]}](#{review_data[:gitlab_project_url]})"
    }
  end

  def self.pivotal_section(story_id)
    {
      activityImage: 'https://bath-webhooks.herokuapp.com/tracker_icon.png',
      activityTitle: "[##{story_id}](https://www.pivotaltracker.com/story/show/#{story_id})"
    }
  end

  def self.send_card(data)
    request = Net::HTTP::Post.new(TEAMS_WEBHOOK_URL, TEAMS_HEADER)
    request.body = (common_data.merge data).to_json
    Rails.logger.info("Outbound POST #{TEAMS_WEBHOOK_URL}: #{request.body}")
    teams_http.request(request)
  end

  def self.teams_http
    uri = URI.parse(TEAMS_WEBHOOK_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http
  end

  def self.common_data
    {
      '@type' => 'MessageCard',
      '@context' => 'http://schema.org/extensions',
      correlationId: SecureRandom.uuid
    }
  end
end
