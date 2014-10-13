require 'test_helper'

class MissionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get progress" do
    get :progress
    assert_response :success
  end

end
