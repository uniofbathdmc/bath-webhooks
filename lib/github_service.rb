require 'net/http'

module GithubService
  KNOWN_PROJECTS = [
    ENV['TYPECASE_PIVOTAL_ID'], # Typecase
    ENV['TYPECASE_FOR_COURSES_PIVOTAL_ID'], # Typecase for Courses
    ENV['BLOGS_PIVOTAL_ID'], # Blogs
  ].freeze
  PIVOTAL_API_URL = 'https://www.pivotaltracker.com/services/v5/'.freeze
  PIVOTAL_TOKEN = ENV['PIVOTAL_API_TOKEN'].freeze
  PIVOTAL_HEADER = { 'Content-Type' => 'application/json',
                     'X-TrackerToken' => PIVOTAL_TOKEN }.freeze
  PIVOTAL_USERS = YAML.load(ENV['PIVOTAL_USER_IDS']).freeze

  def self.handle_payload(payload)
    if payload['review']['state'] == 'approved'
      # Review is submitted or dismissed from "approved" state.

      # Read the PR comment to determine the affected stor(y|ies)
      pr_comment = payload['pull_request']['body']
      stories = pr_comment.scan(/\[[^\]]*\]/).map { |brace| brace.scan(/(?<=#)\d*/) }.flatten

      stories.each do |story|
        if payload['action'] == 'submitted'
          add_reviewed_label(story, payload)
        elsif payload['action'] == 'dismissed'
          remove_reviewed_label(story, payload)
        end
      end
    end
  end

  def self.add_reviewed_label(story, payload)
    project = get_project_for_story(story)
    uri = URI.parse(PIVOTAL_API_URL + "projects/#{project}/stories/#{story}/labels")
    data = { name: 'reviewed' }
    make_pivotal_post(uri, data)
    write_added_label_comment(project, story, payload)
  end

  def self.remove_reviewed_label(story, payload)
    project = get_project_for_story(story)
    labels = get_labels_for_story(project, story)
    reviewed_label = labels.detect { |l| l['name'] == 'reviewed' }
    if reviewed_label
      reviewed_label_id = reviewed_label['id']
      uri = URI.parse(PIVOTAL_API_URL + "projects/#{project}/stories/#{story}/labels/#{reviewed_label_id}")
      make_pivotal_delete(uri)
      write_removed_label_comment(project, story, payload)
    end
  end

  def self.write_added_label_comment(project, story, payload)
    user_id = get_user_id_from_payload(payload)
    uri = URI.parse(PIVOTAL_API_URL + "projects/#{project}/stories/#{story}/comments")
    data = { text: 'Reviewed OK', person_id: user_id }
    make_pivotal_post(uri, data)
  end

  def self.write_removed_label_comment(project, story, payload)
    user_id = get_user_id_from_payload(payload)
    uri = URI.parse(PIVOTAL_API_URL + "projects/#{project}/stories/#{story}/comments")
    data = { text: 'Dismissed review', person_id: user_id }
    make_pivotal_post(uri, data)
  end

  def self.get_user_id_from_payload(payload)
    PIVOTAL_USERS[payload['review']['user']['login']]
  end

  def self.get_project_for_story(story)
    KNOWN_PROJECTS.detect do |proj_id|
      uri = URI.parse(PIVOTAL_API_URL + "projects/#{proj_id}/stories/#{story}")
      response = make_pivotal_get(uri)
      response.code_type == Net::HTTPOK
    end
  end

  def self.get_labels_for_story(project, story)
    uri = URI.parse(PIVOTAL_API_URL + "projects/#{project}/stories/#{story}/labels")
    resp = make_pivotal_get(uri)
    if resp.code_type == Net::HTTPOK
      JSON.parse(resp.read_body)
    else
      []
    end
  end

  def self.make_pivotal_get(uri)
    request = Net::HTTP::Get.new(uri.request_uri, PIVOTAL_HEADER)
    pivotal_http.request(request)
  end

  def self.make_pivotal_post(uri, data)
    request = Net::HTTP::Post.new(uri.request_uri, PIVOTAL_HEADER)
    request.body = data.to_json
    pivotal_http.request(request)
  end

  def self.make_pivotal_delete(uri)
    request = Net::HTTP::Delete.new(uri.request_uri, PIVOTAL_HEADER)
    pivotal_http.request(request)
  end

  def self.pivotal_http
    uri = URI.parse(PIVOTAL_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http
  end
end
