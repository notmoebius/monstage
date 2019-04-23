require 'test_helper'

module InternshipOffers
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # content checks
    #
    test 'GET #show website url when present' do
      internship_offer = create(:internship_offer, employer_website: 'http://google.com')
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select "a.external[href=?]", internship_offer.employer_website
    end

    test 'GET #show does not show website url when absent' do
      internship_offer = create(:internship_offer, employer_website: nil)
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select "a.external", 0
    end

    #
    # internship_applications checks
    #
    test 'GET #show displays application form for student' do
      sign_in(create(:student))
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select "form[id=?]", "new_internship_application"
    end

    test "GET #show as a student who can apply shows an enabled button with candidate label" do
      weeks = [Week.find_by(number:1, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      sign_in(create(:student, school: create(:school, weeks: weeks)))

      get internship_offer_path(internship_offer)
      assert_select "#new_internship_application", 1
      assert_select 'option', text: weeks.first.select_text_method, count: 1
      assert_select 'a[href=?]', "#internship-application-form", count: 1
    end

    test "GET #show as a student who can apply to limited internship offer shows a disabled button with contact SchoolManager label" do
      weeks = [Week.find_by(number:1, year: 2020)]
      student = create(:student, school: create(:school, weeks: weeks))
      internship_offer = create(:internship_offer, school: student.school, weeks: weeks)
      sign_in(student)
      get internship_offer_path(internship_offer)

      assert_select '.alert.alert-info', text: "Ce stage est reservé au #{internship_offer.school}, afin de candidater prenez contact avec votre chef d'etablissement",
                                         count: 1
      assert_select "#new_internship_application", 0
    end

    test "GET #show as a student displays weeks that matches school weeks" do
      internship_weeks = [Week.find_by(number: 1, year: 2020),
                          Week.find_by(number: 2, year: 2020),
                          Week.find_by(number: 3, year: 2020),
                          Week.find_by(number: 4, year: 2020)]
      school = create(:school, weeks: [internship_weeks[1], internship_weeks[2]])
      internship_offer = create(:internship_offer, weeks: internship_weeks)
      sign_in(create(:student, school: school))

      get internship_offer_path(internship_offer)

      assert_select 'select option', text: internship_weeks[0].select_text_method, count: 0
      assert_select 'select option', text: internship_weeks[1].select_text_method, count: 1
      assert_select 'select option', text: internship_weeks[2].select_text_method, count: 1
      assert_select 'select option', text: internship_weeks[3].select_text_method, count: 0
    end

    test "GET #show as a student only displays weeks that are not blocked" do
      max_candidates = 2
      internship_weeks = [Week.find_by(number: 1, year: 2020),
                          Week.find_by(number: 2, year: 2020)]
      school = create(:school, weeks: internship_weeks)
      blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                              week: internship_weeks[0])
      available_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
      internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                   internship_offer_weeks: [ blocked_internship_week,
                                                                             available_internship_week])
      sign_in(create(:student, school: school))
      get internship_offer_path(internship_offer)

      assert_select 'select option', text: blocked_internship_week.week.select_text_method, count: 0
      assert_select 'select option', text: available_internship_week.week.select_text_method, count: 1
    end

    test "GET #show as student with existing draft application shows the draft" do
      weeks = [Week.find_by(number:1, year: 2020), Week.find_by(number:2, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      student = create(:student, school: create(:school, weeks: weeks))
      internship_application = create(:internship_application, :drafted, motivation: 'au taquet',
                                                                         student: student,
                                                                         internship_offer: internship_offer,
                                                                         week: weeks.last)
      sign_in(student)
      get internship_offer_path(internship_offer)
      assert_response :success
      assert_select "option[value=#{internship_offer.internship_offer_weeks.first.id}]"
      assert_select "option[value=#{internship_offer.internship_offer_weeks.last.id}][selected]"
    end

    test "GET #show as student with existing submitted, approved, rejected application shows _state component" do
      weeks = [Week.find_by(number:1, year: 2020), Week.find_by(number:2, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      student = create(:student, school: create(:school, weeks: weeks))
      internship_applications = {
          submitted: create(:internship_application, :submitted, student: student),
          approved: create(:internship_application, :approved, student: student),
          rejected: create(:internship_application, :rejected, student: student),
          convention_signed: create(:internship_application, :convention_signed, student: student)
      }
      sign_in(student)
      get internship_offer_path(internship_offer)
      assert_response :success
      internship_applications.each do |aasm_state, internship_application|
        assert_template "dashboard/students/internship_applications/states/_#{aasm_state}"
      end
    end
  end
end
