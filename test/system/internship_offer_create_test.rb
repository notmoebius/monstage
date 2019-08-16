# frozen_string_literal: true

require 'application_system_test_case'
# TODO: webmock
class InternshipOffersCreateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'can create internship offer' do
    schools = [create(:school), create(:school)]
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit '/dashboard'
        click_on 'Déposer une offre'
        fill_in 'internship_offer_title', with: 'Stage de dev @betagouv.fr ac Brice & Martin'
        fill_in 'internship_offer_description', with: "Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment creer les outils qui feront le monde de demain"
        select sectors.first.name, from: 'internship_offer_sector_id'
        find(:css, "label[for=internship_offer_week_ids_#{available_weeks.first.id}]").click
        find(:css, "label[for=internship_offer_week_ids_#{available_weeks.last.id}]").click
        fill_in 'Nom du tuteu/trice', with: 'Brice Durand'
        fill_in 'Adresse électronique (ex : mon@exemple.fr)', with: 'le@brice.durand'
        fill_in 'Téléphone (ex : 06 12 34 56 78)', with: '0639693969'
        fill_in "Nom de la structure ou du service proposant l'offre", with: 'BetaGouv'
        fill_in "Description de l'organisme accueillant (facultatif)", with: "On fait des startup d'état qui déchirent"
        fill_in 'Site web (facultatif)', with: 'https://beta.gouv.fr/'
        find('label', text: 'public').click
        select Group::PUBLIC.first, from: 'internship_offer_group'
        fill_in 'Adresse du lieu où se déroule le stage', with: 'Paris, 13eme'
        page.all('.algolia-places div[role="option"]')[0].click
        click_on "Enregistrer et publier l'offre"
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
  end
end
