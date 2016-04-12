class WelcomeController < ApplicationController
  def index
  end

  def build
    # Get any builds from today
    @builds = BuildInfo.where(time: Time.now.all_day).order(time: :desc).limit(5)
  end
end
