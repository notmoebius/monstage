class InternshipApplicationCountersHook
  delegate :internship_offer, to: :internship_application
  delegate :internship_offer_week, to: :internship_application

  def update_all_counters
    update_internship_offer_counters
    update_internship_offer_week_counters
  end

  # PERF: maybe optimization path to group those queries?
  def update_internship_offer_counters
    internship_offer.update(
      blocked_weeks_count: internship_offer.internship_offer_weeks
                                           .where("internship_offer_weeks.blocked_applications_count > 0")
                                           .count,
      total_applications_count: internship_offer.internship_applications
                                                .count,
      approved_applications_count: internship_offer.internship_offer_weeks
                                                   .sum(:blocked_applications_count),
    )
  end

  # PERF: can be optimized with one query
  # w8 for perf issue [if it ever occures]
  # select sum(aasm_state == convention_signed) as convention_signed_count
  #        sum(aasm_state == approved) as approved_count )
  def update_internship_offer_week_counters
    internship_offer_week.update(
      blocked_applications_count: internship_offer_week.internship_applications
                                                       .where(aasm_state: :convention_signed)
                                                       .count,
      approved_applications_count: internship_offer_week.internship_applications
                                                       .where(aasm_state: :approved)
                                                       .count,
    )
  end

  attr_reader :internship_application

  private
  def initialize(internship_application:)
    @internship_application = internship_application
  end
end
