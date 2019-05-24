module Reporting
  class InternshipOffer < ApplicationRecord
    include Yearable

    belongs_to :sector
    delegate :name, to: :sector, prefix: true

    AGGREGATE_FUNCTIONS = [
      "sum(total_applications_count) as total_applications_count",
      "sum(total_male_applications_count) as total_male_applications_count",
      "sum(total_applications_count) - sum(total_male_applications_count) as total_female_applications_count",
      "sum(convention_signed_applications_count) as convention_signed_applications_count",
      "sum(total_male_convention_signed_applications_count) as total_male_convention_signed_applications_count",
      "sum(convention_signed_applications_count) - sum(total_male_convention_signed_applications_count) as total_female_convention_signed_applications_count"
    ]

    scope :by_departement, -> (department:) {
      where(department: department)
    }
    scope :by_group, -> (group:) {
      where(group: group)
    }
    scope :by_academy, -> (academy:) {
      where(academy: academy)
    }

    scope :grouped_by_sector, -> () {
      select("sector_id",
             "count(sector_id) as report_total_count",
             *AGGREGATE_FUNCTIONS)
        .includes(:sector)
        .group(:sector_id)
        .order(:sector_id)
    }

    scope :grouped_by_publicy, -> () {
      select("is_public",
             "count(is_public) as report_total_count",
             *AGGREGATE_FUNCTIONS)
        .group(:is_public)
        .order(:is_public)
    }

    scope :grouped_by_group, -> () {
      select("internship_offers.group",
             "count(internship_offers.group) as report_total_count",
             *AGGREGATE_FUNCTIONS)
        .where(is_public: true)
        .group("internship_offers.group")
        .order("internship_offers.group")
    }
  end
end
