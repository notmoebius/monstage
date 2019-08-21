# frozen_string_literal: true

require 'test_helper'

class NavbarTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @school = create(:school, :with_school_manager)
  end

  test "employer" do
    employer = create(:employer)
    sign_in(employer)
    get employer.custom_dashboard_path
    assert_select(".navbar a[href=\"#{root_path}\"]", count: 1, text: "Accueil")
    assert_select(".navbar a.active", count: 1)
    assert_select(".navbar a.active", text: employer.dashboard_name,
                                        count: 1)
  end

  test "main_teacher" do
    main_teacher = create(:main_teacher, school: @school,
                                         class_room: create(:class_room, school: @school))
    sign_in(main_teacher)
    get main_teacher.custom_dashboard_path
    assert_select(".navbar a[href=\"#{root_path}\"]", count: 0, text: "Accueil")
    assert_select(".navbar a.active", count: 1)
    assert_select(".navbar a.active", text: main_teacher.dashboard_name,
                                        count: 1)
  end

  test "other" do
    other = create(:other, school: @school)
    sign_in(other)
    get other.custom_dashboard_path
    assert_select(".navbar a[href=\"#{root_path}\"]", count: 0, text: "Accueil")
    assert_select(".navbar a.active", count: 1)
    assert_select(".navbar a.active", text: other.dashboard_name,
                                        count: 1)
  end

  test "operator" do
    operator = create(:user_operator)
    sign_in(operator)
    get operator.custom_dashboard_path
    assert_select(".navbar a[href=\"#{root_path}\"]", count: 1, text: "Accueil")
    assert_select(".navbar a.active", count: 1)
    assert_select(".navbar a.active", text: operator.dashboard_name,
                                        count: 1)
  end

  test "school_manager" do
    school_manager = @school.school_manager
    sign_in(school_manager)
    get school_manager.custom_dashboard_path
    assert_select(".navbar a.active", count: 1)
    assert_select(".navbar a.active", text: school_manager.dashboard_name,
                                        count: 1)
  end

  test "student" do
    student = create(:student)
    sign_in(student)
    get student.custom_dashboard_path
    assert_select(".navbar a.active", count: 1)
    assert_select(".navbar a.active", text: student.dashboard_name,
                                        count: 1)
  end

  test "teacher" do
    teacher = create(:teacher, school: @school,
                               class_room: create(:class_room, school: @school))
    sign_in(teacher)
    get teacher.custom_dashboard_path
    assert_select(".navbar a.active", count: 1)
    assert_select(".navbar a.active", text: teacher.dashboard_name,
                                        count: 1)
  end
end