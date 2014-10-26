require 'test_helper'

class ApisControllerTest < ActionController::TestCase
  test "should get trip_infomations" do
    get :trip_infomations
    assert_response :success
  end

end
