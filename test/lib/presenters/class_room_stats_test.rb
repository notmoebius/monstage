# frozen_string_literal: true

require 'test_helper'

module Presenters
  class ClassRoomStatsTest < ActiveSupport::TestCase
    setup do
      @school = create(:school)
      @class_room = create(:class_room, school: @school)
      @class_room_stats = ClassRoomStats.new(class_room: @class_room)
    end

    test '.total_student' do
      create(:student, class_room: @class_room)
      create(:student, class_room: @class_room)
      create(:student, class_room: create(:class_room, school: create(:school)))
      assert_equal 2,
                   @class_room_stats.total_student
    end

    test '.total_student_with_parental_consent' do
      create(:student, class_room: @class_room, has_parental_consent: false)
      create(:student, class_room: @class_room, has_parental_consent: true)
      assert_equal 1,
                   @class_room_stats.total_student_with_parental_consent
    end

    test '.total_student_with_zero_application' do
      student_1 = create(:student, class_room: @class_room)
      student_1_applications = [
        create(:internship_application, :submitted, student: student_1),
        create(:internship_application, :submitted, student: student_1)
      ]

      student_2 = create(:student, class_room: @class_room)
      student_2_applications = [
        create(:internship_application, :submitted, student: student_2),
        create(:internship_application, :submitted, student: student_2)
      ]

      student_3 = create(:student, class_room: @class_room)
      student_4 = create(:student, class_room: @class_room)
      student_5 = create(:student, class_room: @class_room)

      assert_equal 3,
                   @class_room_stats.total_student_with_zero_application
    end

    test '.total_pending_convention_signed' do
      student_1 = create(:student, class_room: @class_room)
      student_1_applications = [
        create(:internship_application, :approved, student: student_1),
        create(:internship_application, :rejected, student: student_1)
      ]

      student_2 = create(:student, class_room: @class_room)
      student_2_applications = [
        create(:internship_application, :convention_signed, student: student_2),
        create(:internship_application, :approved, student: student_2)
      ]

      student_3 = create(:student, class_room: @class_room)
      assert_equal 1,
                   @class_room_stats.total_pending_convention_signed
    end

    test '.total_student_with_zero_internship' do
      student_1 = create(:student, class_room: @class_room)
      student_1_applications = [
        create(:internship_application, :approved, student: student_1),
        create(:internship_application, :rejected, student: student_1)
      ]
      student_2 = create(:student, class_room: @class_room)
      student_2_applications = [
        create(:internship_application, :convention_signed, student: student_2),
        create(:internship_application, :approved, student: student_2)
      ]

      student_3 = create(:student, class_room: @class_room)

      assert_equal 2, @class_room_stats.total_student_with_zero_internship
    end
  end
end
