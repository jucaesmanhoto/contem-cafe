require "test_helper"

class ReferralsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @referrer = Referral.create!(name: "Maria", phone: "11999999999")
  end

  test "show renders for a valid token without authentication" do
    get referral_path(@referrer.token)
    assert_response :success
  end

  test "show returns 404 for an unknown token" do
    get referral_path("does-not-exist")
    assert_response :not_found
  end

  test "create with a valid referrer_token creates a new referral and redirects to success" do
    assert_difference "Referral.count", 1 do
      post referrals_path, params: {
        referrer_token: @referrer.token,
        name: "João",
        phone: "11888888888"
      }
    end

    new_referral = Referral.last
    assert_equal @referrer, new_referral.referrer
    assert_redirected_to success_referral_path(new_referral.token)
  end

  test "create with a missing/invalid referrer_token does not create a referral" do
    assert_no_difference "Referral.count" do
      post referrals_path, params: {
        referrer_token: "bogus",
        name: "João",
        phone: "11888888888"
      }
    end
    assert_redirected_to root_path
  end

  test "create with invalid params re-renders the form" do
    assert_no_difference "Referral.count" do
      post referrals_path, params: {
        referrer_token: @referrer.token,
        name: "",
        phone: ""
      }
    end
    assert_response :unprocessable_entity
  end

  test "success renders for a valid token" do
    get success_referral_path(@referrer.token)
    assert_response :success
  end
end
