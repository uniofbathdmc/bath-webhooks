module WelcomeHelper
  def repo_class_from_commit_array(commits)
    commits.empty? ? 'clean' : 'dirty'
  end
end
