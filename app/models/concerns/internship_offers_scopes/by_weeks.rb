module InternshipOffersScopes
  # find internship having the same weeks as user.school.week
  module ByWeeks
    extend ActiveSupport::Concern

    included do
      scope :internship_offers_overlaping_school_weeks, -> (weeks:) {
        InternshipOffer.by_weeks(weeks: weeks)
      }
    end
  end
end
