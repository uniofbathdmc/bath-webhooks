# frozen_string_literal: true

require 'net/http'

# Service providing methods to query the Gitlab API
module GitlabApiService
  # Request the name and description of a repository. Return :not_found if request fails
  def self.repo_details(repo:)
    begin
      repo = client.project repo
    rescue Gitlab::Error
      return :not_found
    end

    [repo.name, repo.description]
  end

  # Request a comparison between two branches, returning an array of the commit messages
  # for the commits by which they differ.
  def self.branch_compare(repo:, base:, head:)
    begin
      compare = client.compare(repo, base, head)
    rescue Gitlab::Error
      return :not_found
    end

    compare.commits.map { |c| c['message'] }
  end

  def self.client
    @client ||= Gitlab.client(private_token: ENV['GITLAB_API_TOKEN'], httparty: { verify: false })
    @client
  end
end

Gitlab.configure do |c|
  c.endpoint = ENV['GITLAB_API_URL'] if ENV.key?('GITLAB_API_URL')
end
