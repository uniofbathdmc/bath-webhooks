class WelcomeController < ApplicationController
  def index
  end

  def build
    if $build_info.present?
      limit = 1.minutes.ago
      @recent_build = ($build_info[:time] > limit)
    else
      @recent_build = false
    end
  end
end
