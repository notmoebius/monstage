require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  test "Visitor" do
    ability = Ability.new()
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internships')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test "Student" do
    student = create(:student)
    ability = Ability.new(student)
    internship_application = create(:internship_application, student: student)
    assert(ability.can?(:read, InternshipOffer.new),
           'students should be able to consult internship offers')
    assert(ability.can?(:apply, InternshipOffer.new),
           'students should be able to apply for internship offers')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'students should not be able to con manage internships')
    assert(ability.can?(:show, :account),
           'students should be able to access their account')
    assert(ability.can?(:choose_school, :sign_up),
           'student should be able to choose_school')
    assert(ability.can?(:choose_class_room, :sign_up),
           'student should be able to choose_class_room')
    assert(ability.can?(:choose_gender_and_birthday, :sign_up),
           'student should be able to choose_gender_and_birthday')
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:internship_application)))
  end

  test "Employer" do
    employer = create(:employer)
    ability = Ability.new(employer)
    assert(ability.can?(:create, InternshipOffer.new),
           'employers should be able to create internships')
    assert(ability.cannot?(:update, InternshipOffer.new),
           'employers should not be able to update internship offer not belonging to him')
    assert(ability.can?(:update, InternshipOffer.new(employer: employer)),
           'employers should be able to update internships offer that belongs to him')
    assert(ability.cannot?(:destroy, InternshipOffer.new),
           'employers should be able to destroy internships offer not belonging to him')
    assert(ability.can?(:destroy, InternshipOffer.new(employer: employer)),
           'employers should be able to destroy internships offer that belongs to him')
  end

  test "God" do
    ability = Ability.new(build(:god))
    assert(ability.can?(:show, :account),
           'god should be able to see his account')
    assert(ability.can?(:manage, School),
           'god should be able to manage school')
    assert(ability.cannot?(:edit, User),
           'god should not be able to edit user')
  end

  test 'SchoolManager' do
    student = create(:student)
    school_manager = create(:school_manager, school: student.school)
    internship_application = create(:internship_application, student: student)
    ability = Ability.new(school_manager)
    assert(ability.cannot?(:show, School),
           'school_manager should be able show school')
    assert(ability.can?(:show , ClassRoom))
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:internship_application)))
  end

  test 'MainTeacher' do
    ability = Ability.new(build(:main_teacher))
    assert(ability.can?(:show, :account),
           'students should be able to access their account')
    assert(ability.can?(:choose_school, :sign_up),
           'student should be able to choose_school')
    assert(ability.can?(:choose_class_room, :sign_up),
           'student should be able to choose_class_room')
    assert(ability.can?(:show, ClassRoom))
    assert(ability.can?(:index, ClassRoom))
  end
end
