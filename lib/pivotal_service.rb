# frozen_string_literal: true

module PivotalService
  KNOWN_PROJECTS = [
    ENV['TYPECASE_PIVOTAL_ID'], # Typecase
    ENV['TYPECASE_FOR_COURSES_PIVOTAL_ID'], # Typecase for Courses
    ENV['BLOGS_PIVOTAL_ID'], # Blogs
    ENV['PATTERN_LIBRARY_PIVOTAL_ID'], # Pattern library
    ENV['INFRASTRUCTURE_PIVOTAL_ID'], # Infrastructure
  ].freeze
  PIVOTAL_API_URL = 'https://www.pivotaltracker.com/services/v5/'
  PIVOTAL_TOKEN = ENV['PIVOTAL_API_TOKEN'].freeze
  PIVOTAL_HEADER = { 'Content-Type' => 'application/json',
                     'X-TrackerToken' => PIVOTAL_TOKEN }.freeze
  PIVOTAL_USERS = YAML.safe_load(ENV['PIVOTAL_USER_IDS']).freeze

  # Class member hash from story IDs to their project IDs. Probably only lasts one request, but means we
  # don't have to spam Pivotal to get the full story URL with project repeatedly.
  @story_projects = {}

  def self.add_reviewed_label(story, user_name)
    uri = URI.parse(url_for_story(story))
    data = { name: 'reviewed' }
    make_pivotal_post(uri, data)
    write_added_label_comment(story, user_name)
  end

  def self.remove_reviewed_label(story, user_name)
    labels = get_labels_for_story(story)
    reviewed_label = labels.detect { |l| l['name'] == 'reviewed' }
    return unless reviewed_label

    reviewed_label_id = reviewed_label['id']
    uri = URI.parse(url_for_story(story) + "/labels/#{reviewed_label_id}")
    make_pivotal_delete(uri)
    write_removed_label_comment(story, user_name)
  end

  def self.write_added_label_comment(story, user_name)
    uri = URI.parse(url_for_story(story) + '/comments')
    data = { text: 'Reviewed OK', person_id: PIVOTAL_USERS[user_name] }
    make_pivotal_post(uri, data)
  end

  def self.write_removed_label_comment(story, user_name)
    uri = URI.parse(url_for_story(story) + '/comments')
    data = { text: 'Dismissed review', person_id: PIVOTAL_USERS[user_name] }
    make_pivotal_post(uri, data)
  end

  def self.url_for_story(story)
    PIVOTAL_API_URL + "projects/#{project_id_for_story(story)}/stories/#{story}" }
  end

  def self.project_id_for_story(story)
    return @story_projects[story] if @story_projects.key? story
    proj_id = KNOWN_PROJECTS.detect do |project|
      url = PIVOTAL_API_URL + "projects/#{project}/stories/#{story}"
      response = make_pivotal_get(URI.parse(url))
      response.code_type == Net::HTTPOK
    end

    # Implicitly return proj_id
    @story_projects[story] = proj_id
  end

  def self.get_labels_for_story(story)
    uri = URI.parse(url_for_story(story) + '/labels')
    resp = make_pivotal_get(uri)
    if resp.code_type == Net::HTTPOK
      JSON.parse(resp.read_body)
    else
      []
    end
  end

  def self.get_story_title(story_id)
    uri = URI.parse(url_for_story(story_id))
    resp = make_pivotal_get(uri)
    if resp.code_type == Net::HTTPOK
      story_data = JSON.parse(resp.read_body)
      story_data['name']
    else
      ''
    end
  end

  def self.get_project_name(project_id)
    uri = URI.parse(PIVOTAL_API_URL + "projects/#{project_id}")
    resp = make_pivotal_get(uri)
    if resp.code_type == Net::HTTPOK
      project_data = JSON.parse(resp.read_body)
      project_data['name']
    else
      ''
    end
  end

  def self.make_pivotal_get(uri)
    request = Net::HTTP::Get.new(uri.request_uri, PIVOTAL_HEADER)
    Rails.logger.info("Outbound GET #{uri.request_uri}")
    pivotal_http.request(request)
  end

  def self.make_pivotal_post(uri, data)
    request = Net::HTTP::Post.new(uri.request_uri, PIVOTAL_HEADER)
    request.body = data.to_json
    Rails.logger.info("Outbound POST #{uri.request_uri}: #{request.body}")
    pivotal_http.request(request)
  end

  def self.make_pivotal_delete(uri)
    request = Net::HTTP::Delete.new(uri.request_uri, PIVOTAL_HEADER)
    Rails.logger.info("Outbound DELETE #{uri.request_uri}")
    pivotal_http.request(request)
  end

  def self.pivotal_http
    uri = URI.parse(PIVOTAL_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http
  end
end
