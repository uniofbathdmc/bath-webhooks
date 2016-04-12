require 'test_helper'

class BuildInfosControllerTest < ActionController::TestCase
  setup do
    @build_info = build_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:build_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create build_info" do
    assert_difference('BuildInfo.count') do
      post :create, build_info: { colour: @build_info.colour, display: @build_info.display, time: @build_info.time }
    end

    assert_redirected_to build_info_path(assigns(:build_info))
  end

  test "should show build_info" do
    get :show, id: @build_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @build_info
    assert_response :success
  end

  test "should update build_info" do
    patch :update, id: @build_info, build_info: { colour: @build_info.colour, display: @build_info.display, time: @build_info.time }
    assert_redirected_to build_info_path(assigns(:build_info))
  end

  test "should destroy build_info" do
    assert_difference('BuildInfo.count', -1) do
      delete :destroy, id: @build_info
    end

    assert_redirected_to build_infos_path
  end
end
