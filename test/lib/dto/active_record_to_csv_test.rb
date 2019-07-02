# frozen_string_literal: true

require 'test_helper'
module Dto
  class ActiveRecordToCsvTest < ActiveSupport::TestCase
    test '.to_csv empty result, with Array headers' do
      converter = ActiveRecordToCsv.new(entries: [], headers: %w[col1 col2 col3])
      assert_equal "col1,col2,col3\n", converter.to_csv
    end

    test '.to_csv empty result, with Hash headers' do
      converter = ActiveRecordToCsv.new(entries: [],
                                        headers: {
                                          col1: "Foo",
                                          col2: "Bar",
                                          col3: 'Baz'
                                        })
      assert_equal "Foo,Bar,Baz\n", converter.to_csv
    end

    test '.to_csv model' do
      internship_offer_1 = create(:internship_offer, title: "1-title", description: "1-desc")
      internship_offer_2 = create(:internship_offer, title: "2-title", description: "2-desc")

      converter = ActiveRecordToCsv.new(entries: InternshipOffer.all, headers: %w[title description])
      header_row = "title,description"
      row_1 = "#{internship_offer_1.title},#{internship_offer_1.description}"
      row_2 = "#{internship_offer_2.title},#{internship_offer_2.description}"
      assert_equal [header_row, row_1, row_2, ""].join("\n"),
                   converter.to_csv
    end

    test ".to_csv with Reporting::InternshipOffer" do
      sector_agri = create(:sector, name: 'Agriculture')
      sector_wood = create(:sector, name: 'Filière bois')
      internship_offer_agri_1 = create(:internship_offer, sector: sector_agri, max_candidates: 1, max_internship_week_number: 2)
      internship_offer_agri_2 = create(:internship_offer, sector: sector_agri, max_candidates: 1, max_internship_week_number: 2)
      internship_offer_wood = create(:internship_offer, sector: sector_wood, max_candidates: 10, max_internship_week_number: 2)

      results = Reporting::InternshipOffer.grouped_by_sector.all
      headers = {
        sector_name: Reporting::InternshipOffer.i18n_attribute(:sector_id)
      }
      converter = ActiveRecordToCsv.new(entries: results, headers: Reporting::InternshipOffer.csv_headers(headers: headers))
      header_row = "Secteurs professionnels,Nbr. d'offres proposées,Nombre de candidatures,Garçon,Fille,Nombre de stages conclus,Garçon,Fille"
      row_1 = "#{sector_agri.name},4,0,0,0,0,0,0"
      row_2 = "#{sector_wood.name},20,0,0,0,0,0,0"
      assert_equal [header_row, row_1, row_2, ""].join("\n"),
                   converter.to_csv
    end
  end
end
