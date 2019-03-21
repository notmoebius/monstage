require "application_system_test_case"

class SignUpMainTeachersTest < ApplicationSystemTestCase
  driven_by :selenium, using: :chrome

  test "navigation & interaction works until student creation" do
    school_1 = create(:school, name: "Collège Test 1", city: "Saint-Martin")
    school_manager = create(:school_manager, school: school_1)
    school_2 = create(:school, name: "Collège Test 2", city: "Saint-Parfait")
    class_room_1 = create(:class_room, name: "3e A", school: school_1)
    class_room_2 = create(:class_room, name: "3e B", school: school_2)
    existing_email = 'fourcade.m@gmail.com'
    birth_date = 14.years.ago
    student = create(:student, email: existing_email)

    # go to signup as student
    visit "/"
    click_on "Inscription"
    find("#dropdown-choose-profile").click
    click_on "Professeur principal"

    # fails to create student with existing email
    assert_difference('Users::MainTeacher.count', 0) do
      find_field("Ville de mon collège").fill_in(with: "Saint")
      find("a", text: school_1.city).click
      find("label", text: "#{school_1.name} - #{school_1.city}").click
      select(class_room_1.name, from: "user_class_room_id")
      fill_in "Mon prénom", with: "Martin"
      fill_in "Mon nom", with: "Fourcade"
      fill_in "Mon courriel", with: existing_email
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # ensure failure reset form as expected
    assert_equal school_1.city,
                 find_field("Ville de mon collège").value,
                 "re-select of city after failure fails"

    # create student
    assert_difference('Users::MainTeacher.count', 1) do
      fill_in "Mon courriel", with: "another@email.com"
      fill_in "Mon mot de passe", with: "kikoololletest"
      fill_in "Confirmation de mon mot de passe", with: "kikoololletest"
      click_on "Je m'inscris"
    end

    # check created student has valid info
    created_main_teacher = Users::MainTeacher.where(email: "another@email.com").first
    assert_equal school_1, created_main_teacher.school
    assert_equal class_room_1, created_main_teacher.class_room
    assert_equal "Martin", created_main_teacher.first_name
    assert_equal "Fourcade", created_main_teacher.last_name
  end
end