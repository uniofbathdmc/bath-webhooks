require 'github_api_service'

class WelcomeController < ApplicationController
  REPOS_TO_CHECK = YAML.safe_load(ENV['REPOS_TO_CHECK']).freeze

  def index
  end

  def build
    # Get any builds from today
    @builds = BuildInfo.where(time: Time.now.all_day).order(time: :desc).limit(5)
  end

  def repo_statuses
    @repo_statuses = REPOS_TO_CHECK.map do |repo_hash|
      details = GithubApiService.repo_details(repo: repo_hash['name'])
      {
        name: details[0],
        descr: details[1],
        commits: GithubApiService.branch_compare(repo: repo_hash['name'],
                                                 base: repo_hash['base'],
                                                 head: repo_hash['head'])
      }
    end
  end
end
