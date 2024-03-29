# frozen_string_literal: true

require 'test_helper'

module Api
  class UpdateTest < ActionDispatch::IntegrationTest
    include ApiTestHelpers

    setup do
      @operator = create(:user_operator)
      @internship_offer = create(:api_internship_offer, employer: @operator)
    end

    test 'PATCH #update without token renders :unauthorized payload' do
      documents_as(endpoint: :'internship_offers/update', state: :unauthorized) do
        patch api_internship_offer_path(id: @internship_offer.remote_id)
      end
      assert_response :unauthorized
      assert_equal 'UNAUTHORIZED', json_response['code']
      assert_equal 'wrong api token', json_error
    end

    test 'PATCH #update as operator fails with invalid payload respond with :unprocessable_entity' do
      documents_as(endpoint: :'internship_offers/update', state: :unprocessable_entity) do
        patch api_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{@operator.api_token}"
          }
        )
      end
      assert_response :unprocessable_entity
      assert_equal 'BAD_PAYLOAD', json_response['code']
      assert_equal 'param is missing or the value is empty: internship_offer', json_error
    end

    test 'PATCH #update an internship_offer which does not belongs to current auth operator' do
      bad_operator = create(:user_operator)
      documents_as(endpoint: :'internship_offers/update', state: :forbidden) do
        patch api_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{bad_operator.api_token}",
            internship_offer: {
              title: ''
            }
          }
        )
      end
      assert_response :forbidden
      assert_equal 'FORBIDDEN', json_response['code']
      assert_equal 'You are not authorized to access this page.', json_error
    end

    test 'PATCH #update as operator fails with invalid remote_id' do
      documents_as(endpoint: :'internship_offers/update', state: :not_found) do
        patch api_internship_offer_path(
          id: 'foo',
          params: {
            token: "Bearer #{@operator.api_token}",
            internship_offer: {
              description: 'a' * (BaseInternshipOffer::OLD_DESCRIPTION_MAX_CHAR_COUNT + 2)
            }
          }
        )
      end
      assert_response :not_found
      assert_equal 'NOT_FOUND', json_response['code']
      assert_equal "can't find internship_offer with this remote_id", json_error
    end

    test 'PATCH #update as operator fails with invalid data respond with :bad_request' do
      documents_as(endpoint: :'internship_offers/update', state: :bad_request) do
        patch api_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{@operator.api_token}",
            internship_offer: {
              description: 'a' * (BaseInternshipOffer::OLD_DESCRIPTION_MAX_CHAR_COUNT + 2)
            }
          }
        )
      end
      assert_response :bad_request
      assert_equal 'VALIDATION_ERROR', json_response['code']
      assert_equal ['Description too long, allowed up 500 chars'],
                   json_error['description'],
                   'bad description error '
    end

    test 'PATCH #update as operator works to internship_offers' do
      new_title = 'hellow'
      week_instances = [weeks(:week_2019_1), weeks(:week_2019_2)]
      week_params = [
        "#{week_instances.first.year}-W#{week_instances.first.number}",
        "#{week_instances.last.year}-W#{week_instances.last.number}"
      ]

      documents_as(endpoint: :'internship_offers/update', state: :ok) do
        patch api_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{@operator.api_token}",
            internship_offer: {
              title: new_title,
              weeks: week_params,
              max_candidates: 2
            }
          }
        )
      end
      assert_response :success
      assert_equal new_title, @internship_offer.reload.title
      assert_equal week_instances, @internship_offer.reload.weeks
      assert_equal 2, @internship_offer.max_candidates
      assert_equal JSON.parse(@internship_offer.to_json), json_response
    end
  end
end
