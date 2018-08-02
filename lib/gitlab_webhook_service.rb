# frozen_string_literal: true

require 'net/http'
require 'pivotal_service'

# Service providing an endpoint for Gitlab webhooks
module GitlabWebhookService
  def self.handle_payload(payload)
    # We're currently handling only Merge Request changes - +/- reviewed label
    old_label_names = payload['changes']['labels']['previous'].map { |l| l['title'] }
    new_label_names = payload['changes']['labels']['current'].map { |l| l['title'] }

    return unless old_label_names.include?('reviewed') != new_label_names.include?('reviewed')

    user_name = get_user_name_from_payload(payload)
    stories_from_payload(payload).each do |story|
      if new_label_names.include?('reviewed')
        PivotalService.add_reviewed_label(story, user_name)
      else
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
end
