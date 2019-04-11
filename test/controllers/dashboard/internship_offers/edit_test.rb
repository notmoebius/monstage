require 'test_helper'


module InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #edit as visitor redirects to user_session_path' do
      get edit_dashboard_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to user_session_path
    end

    test 'GET #edit as employer not owning internship_offer redirects to user_session_path' do
      sign_in(create(:employer))
      get edit_dashboard_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to root_path
    end

    test 'GET #edit as employer owning internship_offer renders success' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer = create(:internship_offer, employer: employer,
                                                   max_candidates: 2,
                                                   max_internship_week_number: 4)
      get edit_dashboard_internship_offer_path(internship_offer.to_param)
      assert_select "#internship_offer_max_internship_week_number[value=#{internship_offer.max_internship_week_number}]", count: 1
      assert_select "#internship_offer_max_candidates[value=#{internship_offer.max_candidates}]", count: 1
      assert_response :success
    end
  end
end