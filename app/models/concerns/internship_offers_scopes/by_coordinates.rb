module InternshipOffersScopes
  # find internship in a 60km radious from user.school
  module ByCoordinates
    extend ActiveSupport::Concern

    included do
      scope :internship_offers_nearby_from_school, -> (coordinates:) {
        InternshipOffer.nearby(latitude: coordinates.latitude,
                               longitude: coordinates.longitude)
      }
    end
  end
end