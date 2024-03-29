# frozen_string_literal: true

require 'test_helper'

class SchoolSearchTest < ActiveSupport::TestCase
  test 'autocomplete_by_city find stuffs upper or lower case' do
    @paris = create(:api_school, city: "Paris")
    assert_equal 1, Api::School.autocomplete_by_city(term: "PARIS").size, 'find with uppercase fails'
    assert_equal 1, Api::School.autocomplete_by_city(term: "paris").size, 'find with lowercase fails'
  end

  test 'autocomplete_by_city find with or without accent' do
    @orleans = create(:api_school, city: "Orléans")

    assert_equal 1, Api::School.autocomplete_by_city(term: "Orléans").size, 'find with accent'
    assert_equal 1, Api::School.autocomplete_by_city(term: "Orleans").size, 'find without accent'
  end

  test 'autocomplete_by_city find compound cities names' do
    @orleans = create(:api_school, city: "Mantes-la-Jolie")

    assert_equal 1, Api::School.autocomplete_by_city(term: "Mante").size, 'coumpound with missing letter missed'
    assert_equal 1, Api::School.autocomplete_by_city(term: "Mantes").size, 'compound with single complete word missed'
    assert_equal 1, Api::School.autocomplete_by_city(term: "Mantes-la").size, 'compound halfly spelled with dashes missed'
    assert_equal 1, Api::School.autocomplete_by_city(term: "Mantes-la-Jolie").size, 'compound fully spelled with dashes missed'
    assert_equal 1, Api::School.autocomplete_by_city(term: "Mantes-la-Jolie").size, 'compound fully spelled without dashes missed'
    assert_equal 1, Api::School.autocomplete_by_city(term: "Mantes Jolie").size, 'compound with missing stop word missed'
  end

  test 'autocomplete_by_city returns ordered result (by Levenshtein distance on city.name)' do
    paris = create(:api_school, city: "Paris")
    parisot = create(:api_school, city: "Parisot")
    parisote = create(:api_school, city: "Parisote")
    parisotel = create(:api_school, city: "Parisotel")

    results = Api::School.autocomplete_by_city(term: "Pari")

    assert_equal paris.name, results[0].name
    assert_equal parisot.name, results[1].name
    assert_equal parisote.name, results[2].name
    assert_equal parisotel.name, results[3].name
  end

  test 'autocomplete_by_city return pg_search_highlight' do
    @paris = create(:api_school, city: "paris")
    @paris = create(:api_school, city: "paris blip")
    results = Api::School.autocomplete_by_city(term: "pari")
    assert "<b>paris</b>", results[0].attributes['pg_search_highlight']
    assert "<b>paris</b> blip", results[1].attributes['pg_search_highlight']
  end
end
