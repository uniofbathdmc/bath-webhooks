# frozen_string_literal: true

require 'net/http'

# Service providing methods to query the Github API
module GithubApiService
  # Request the name and description of a repository. Return :not_found if request fails
  def self.repo_details(repo:)
    begin
      repo = client.repository repo
    rescue
      return :not_found
    end

    [repo.name, repo.description]
  end

  # Request a comparison between two branches, returning an array of the commit messages
  # for the commits by which they differ.
  def self.branch_compare(repo:, base:, head:)
    begin
      compare = client.compare(repo, base, head)
    rescue
      return :not_found
    end

    compare.commits.map(&:commit).map(&:message)
  end

  def self.client
    @@client ||= Octokit::Client.new(access_token: ENV['GITHUB_API_TOKEN'])
    @@client
  end
end

Octokit.configure do |c|
  c.api_endpoint = ENV['GITHUB_API_URL'] if ENV.key?('GITHUB_API_URL')
end