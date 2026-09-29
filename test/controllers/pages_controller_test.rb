require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "about coffee page renders without authentication" do
    get about_coffee_path
    assert_response :success
  end
end
