class WelcomeController < ApplicationController
  def index
  end

  def build
    if $build_info.present?
      # true if $build_info[:time] was less than 5 mins ago
      # (greater than DateTime object set to 5 mins before now)
      @recent_build = ($build_info[:time] > 5.minutes.ago)
    else
      @recent_build = false
    end
  end
end
