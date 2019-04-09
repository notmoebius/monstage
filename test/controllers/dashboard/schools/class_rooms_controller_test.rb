require 'test_helper'

module Dashboard
  module Schools
    class ClassRoomsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # bew
      #
      test 'GET new as SchoolManager responds with success' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        class_room_name = SecureRandom.hex
        class_room = create(:class_room, name: class_room_name, school: school)
        sign_in(school_manager)

        get new_dashboard_school_class_room_path(school.to_param)

        assert_response :success
        assert_select "form a[href=?]", account_path
      end

      test 'GET new as Student responds with fail' do
        school = create(:school)
        student = create(:student)
        sign_in(student)
        get new_dashboard_school_class_room_path(school.to_param)
        assert_redirected_to root_path
      end

      #
      # Create
      #
      test 'POST create as SchoolManager responds with success' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        sign_in(school_manager)
        class_room_name = SecureRandom.hex
        assert_difference 'ClassRoom.count' do
          post dashboard_school_class_rooms_path(school.to_param), params: { class_room: { name: class_room_name } }
          assert_redirected_to account_path
        end
        assert_equal 1, ClassRoom.where(name: class_room_name).count
      end

      test 'POST create as Student responds with fail' do
        student = create(:student)
        school = create(:school)
        sign_in(student)
        post dashboard_school_class_rooms_path(school.to_param), params: { class_room: {name: 'test'} }
        assert_redirected_to root_path
      end

      #
      # Edit
      #
      test 'GET edit as SchoolManager render form' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        class_room = create(:class_room, school: school)

        sign_in(school_manager)
        get edit_dashboard_school_class_room_path(school.to_param, class_room.to_param)
        assert_response :success
      end

      #
      # Update
      #
      test 'PATCH update as SchoolManager update class_room' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        class_room = create(:class_room, school: school, name: SecureRandom.hex)
        sign_in(school_manager)
        patch dashboard_school_class_room_path(school, class_room, params: {class_room: { name: 'new_name' }})
        assert_redirected_to account_path
        assert_equal 'new_name', class_room.reload.name
      end

      #
      # Show
      #
      test 'GET show as Student is forbidden' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        sign_in(create(:student, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_redirected_to root_path
      end

      test 'GET show as SchoolManager works' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
      end

      test 'GET show as SchoolManager shows student list' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        students = [
          create(:student, class_room: class_room, school: school),
          create(:student, class_room: class_room, school: school),
          create(:student, class_room: class_room, school: school),
        ]
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_path(school, class_room)
        students.map do |student|
          assert_select "a[href=?]", dashboard_school_class_room_student_path(school, class_room, student)
        end
      end
    end
  end
end
