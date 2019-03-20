require 'test_helper'

class EmployerRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as a Employer' do
    get new_user_registration_path(as: 'Employer')

    assert_response :success
    assert_select 'input', { value: 'Employer', hidden: 'hidden' }
    assert_select 'label', /Mon courriel/
    assert_select 'label', /Mon mot de passe/
    assert_select 'label', /Confirmation de mon mot de passe/
  end

  test 'POST Create Employer' do
    assert_difference("Users::Employer.count") do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Employer' }})
      assert_redirected_to root_path
    end
  end
end