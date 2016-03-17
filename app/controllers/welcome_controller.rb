class WelcomeController < ApplicationController
  def index
  end

  def build
    @builds = BuildInfo.order(time: :desc).limit(10)
  end
end
