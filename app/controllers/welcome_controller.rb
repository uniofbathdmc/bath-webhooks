class WelcomeController < ApplicationController
  def index
  end

  def build
    # Get any builds from today
    @builds = BuildInfo.where(time: Time.now.all_day).order(time: :desc).limit(5)
  end

  def grouped
    @builds = BuildInfo.group_by_day(:time)
  end
end
