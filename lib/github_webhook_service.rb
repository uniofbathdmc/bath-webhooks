# frozen_string_literal: true

require 'net/http'
require 'pivotal_service'

# Service providing an endpoint for Github webhooks
module GithubWebhookService
  def self.handle_payload(payload)
    return unless payload['review']['state'] == 'approved'
    # Review is submitted or dismissed from "approved" state.

    user_id = get_user_id_from_payload(payload)
    stories_from_payload(payload).each do |story|
      if payload['action'] == 'submitted'
        add_reviewed_label(story, user_id)
      elsif payload['action'] == 'dismissed'
        remove_reviewed_label(story, user_id)
      end
    end
  end

  # Read the PR comment to determine the affected stor(y|ies)
  def self.stories_from_payload(payload)
    pr_details = %w[title body].map { |field| payload['pull_request'][field] }
    pr_details.map { |value| value.scan(/\[[^\]]*\]/).map { |brace| brace.scan(/(?<=#)\d*/) } }.flatten
  end

  def self.get_user_id_from_payload(payload)
    PIVOTAL_USERS[payload['review']['user']['login']]
  end
end
