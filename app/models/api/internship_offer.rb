# frozen_string_literal: true

module Api
  class InternshipOffer < ApplicationRecord
    include Nearbyable
    include BaseInternshipOffer

    validates :remote_id,
              :permalink,
              presence: true

    validates :remote_id, uniqueness: { scope: :employer_id }

    after_initialize :init

    def init
      self.max_candidates ||= 1
      self.max_internship_week_number ||= 1
      self.is_public = false
    end

    def formated_coordinates
      {
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      }
    end

    def to_json
      super(
        only: [:title,
               :description,
               :employer_name,
               :employer_description,
               :employer_website,
               :street,
               :zipcode,
               :city,
               :remote_id,
               :permalink,
               :sector_uuid],
        methods: [:formated_coordinates]
      )
    end
  end
end