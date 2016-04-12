class WelcomeController < ApplicationController
  def index
  end

  def build
    @builds = BuildInfo.order(time: :desc).limit(5)
  end
end
