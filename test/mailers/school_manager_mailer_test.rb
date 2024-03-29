# frozen_string_literal: true

require 'test_helper'

class SchoolManagerMailerTest < ActionMailer::TestCase
  test 'new_member' do
    main_teacher = build(:main_teacher)
    school_manager = build(:school_manager)
    email = SchoolManagerMailer.new_member(member: main_teacher,
                                           school_manager: school_manager)
    assert_includes email.to, school_manager.email
    assert_equal "Nouveau Professeur principal: #{main_teacher.first_name} #{main_teacher.last_name}", email.subject
  end
end
