class WelcomeController < ApplicationController
  def index
  end

  def build
    if $time_built.present?
      limit = 1.minutes.ago
      @recent_build = ($time_built > limit)
    else
      @recent_build = false
    end
  end
end
