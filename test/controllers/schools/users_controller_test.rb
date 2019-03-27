require 'test_helper'

module Schools
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'DELETE #destroy not signed in' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = create(:main_teacher, school: school)

      delete school_user_path(school, main_teacher)
      assert_redirected_to new_user_session_path
    end

    test 'DELETE #destroy as main_teacher fails' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = create(:main_teacher, school: school)
      sign_in(main_teacher)
      delete school_user_path(school, main_teacher)
      assert_redirected_to root_path
    end

    test 'DELETE #destroy as SchoolManager succeed' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = create(:main_teacher, school: school)
      sign_in(school_manager)
      assert_changes -> { main_teacher.reload.school } do
        delete school_user_path(school, main_teacher)
      end
      assert_redirected_to account_path
    end
  end
end