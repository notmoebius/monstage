require 'test_helper'

class InternshipApplicationCountersHookTest < ActiveSupport::TestCase
  setup do
    @week = Week.find_by(number: 1, year: 2019)
    @internship_offer_week = build(:internship_offer_week, week: @week)
    @internship_offer = build(:internship_offer, internship_offer_weeks: [@internship_offer_week])
    @internship_application = build(:internship_application, internship_offer_week: @internship_offer_week,
                                                             internship_offer: @internship_offer)
    @hook = InternshipApplicationCountersHook.new(internship_application: @internship_application)
  end


  #
  # tracks internship_offer_weeks counters
  #
  test ".update_internship_offer_week_counters tracks internship_offer_weeks.blocked_applications_count" do
    @internship_application.aasm_state = :approved
    @internship_application.save!
    assert_changes -> { @internship_offer_week.reload.blocked_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.signed!
      @hook.update_internship_offer_week_counters # TODO: remove, plug in callback
    end
  end

  test ".update_internship_offer_week_counters tracks internship_offer_weeks.approved_applications_count" do
    @internship_application.save!

    assert_changes -> { @internship_offer_week.reload.approved_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.approve!
      @hook.update_internship_offer_week_counters # TODO: remove, plug in callback
    end
  end

  #
  # track internship_offer counters
  #
  test ".update_internship_offer_counters tracks internship_offer.blocked_weeks_count" do
    @internship_application.aasm_state = :approved
    @internship_application.save!

    assert_changes -> { @internship_offer.reload.blocked_weeks_count },
                   from: 0,
                   to: 1 do
      @internship_application.signed!
      @hook.update_internship_offer_week_counters
      @hook.update_internship_offer_counters
    end
  end

  test ".update_internship_offer_counters tracks internship_offer.total_applications_count" do
    assert_changes -> { @internship_offer.total_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.save!
      @hook.update_internship_offer_counters
      @internship_offer.reload
    end
  end

  test ".update_internship_offer_counters tracks internship_offer.approved_applications_count" do
    @internship_application.aasm_state = :approved
    @internship_application.save!

    assert_changes -> { @internship_offer.reload.approved_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.signed!
      @hook.update_internship_offer_week_counters
      @hook.update_internship_offer_counters
    end
  end
end