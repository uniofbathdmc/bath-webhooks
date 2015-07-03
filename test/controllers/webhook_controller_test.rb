require 'test_helper'

class WebhookControllerTest < ActionController::TestCase
  test "should get slack" do
    get :slack
    assert_response :success
  end

end
