require 'test_helper'
require 'github_api_service'

# By not specifying the internal github API endpoint in ENV, this test runs against public github.com
class GithubApiServiceTest < ActiveSupport::TestCase
  def test_client_works
    client = GithubApiService.client
    repos = []
    VCR.use_cassette('basic_request', record: :new_episodes) do
      repos = client.repos('uniofbathdmc')
    end

    assert_equal 17, repos.count, 'Expected to see 17 repos'
    assert_includes repos.map(&:name), 'bath-webhooks', 'Expected bath-webhooks repo to be present'
  end

  def test_repo_finds_name_and_description
    result = []
    VCR.use_cassette('repo_info', record: :new_episodes) do
      result = GithubApiService.repo_details(repo: 'rails/rails')
    end

    assert_equal ['rails', 'Ruby on Rails'], result, 'Expected name and description to match'
  end

  def test_missing_repo_reported
    result = []
    VCR.use_cassette('missing_repo_info', record: :new_episodes) do
      result = GithubApiService.repo_details(repo: 'rails/repo-that-doesnt-exist')
    end

    assert_equal :not_found, result, 'Expected name and description to match'
  end

  def test_branch_compare_when_clean
    messages = []
    VCR.use_cassette('clean_branch_compare', record: :new_episodes) do
      messages = GithubApiService.branch_compare(repo: 'bkeepers/dotenv', base: 'master', head: 'release-2.0.2')
    end

    assert_empty messages, 'Expected messages to not be empty'
  end

  def test_branch_compare_when_dirty
    messages = []
    VCR.use_cassette('dirty_branch_compare', record: :new_episodes) do
      messages = GithubApiService.branch_compare(repo: 'vcr/vcr', base: 'master', head: '1-x-stable')
    end

    refute_empty messages, 'Expected messages to not be empty'
    assert_equal ['Only build master and 1-x-stable branches.', 'Remove 1.8.6 build since travis no longer supports it.'], messages, 'Expected messages to be exactly as recorded'
  end
end