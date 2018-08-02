# frozen_string_literal: true

require 'net/http'
require 'pivotal_service'
require 'microsoft_teams_service'

# Service providing an endpoint for Gitlab webhooks
module GitlabWebhookService
  def self.handle_payload(payload)
    # We're currently handling only Merge Request changes - +/- reviewed label
    old_label_names = payload['changes']['labels']['previous'].map { |l| l['title'] }
    new_label_names = payload['changes']['labels']['current'].map { |l| l['title'] }

    return unless old_label_names.include?('reviewed') != new_label_names.include?('reviewed')

    user_name = get_user_name_from_payload(payload)
    story_ids = stories_from_payload(payload)
    if new_label_names.include?('reviewed')
      story_ids.each do |story|
        PivotalService.add_reviewed_label(story, user_name)
      end

      MicrosoftTeamsService.send_reviewed_card(teams_card_data_from_payload(payload), stories: story_ids)
    else
      stories_from_payload(payload).each do |story|
        PivotalService.remove_reviewed_label(story, user_name)
      end
    end
  end

  # Read the MR title and description to determine the affected stor(y|ies)
  def self.stories_from_payload(payload)
    mr_details = %w[title description].map { |field| payload['object_attributes'][field] }
    mr_details.map { |value| value.scan(/\[[^\]]*\]/).map { |brace| brace.scan(/(?<=#)\d*/) } }.flatten
  end

  def self.get_user_name_from_payload(payload)
    payload['user']['username']
  end

  def self.teams_card_data_from_payload(payload)
    {
      gitlab_user: payload['user']['username'],
      gitlab_user_name: payload['user']['name'],
      gitlab_user_avatar_url: payload['user']['avatar_url'],
      gitlab_project_path: payload['project']['path_with_namespace'],
      gitlab_project_url: payload['project']['web_url'],
      gitlab_mr_number: payload['object_attributes']['iid'],
      gitlab_mr_url: payload['object_attributes']['url']
    }
  end
end
