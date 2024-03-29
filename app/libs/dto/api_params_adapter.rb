
module Dto
  # adapt api params to model
  class ApiParamsAdapter
    def sanitize
      map_sector_uuid_to_sector
      map_week_slugs_to_weeks
      assign_offer_to_current_api_user
      params
    end

    private
    attr_reader :params, :user
    def initialize(params:, user:)
      @params = params
      @user = user
    end

    def map_sector_uuid_to_sector
      return params unless params.key?(:sector_uuid)

      params[:sector] = Sector.where(uuid: params.delete(:sector_uuid)).first
      params
    end

    def map_week_slugs_to_weeks
      if params.key?(:weeks)
        concatenated_query = nil
        Array(params.delete(:weeks)).map do |week_str|
          year, number = week_str.split('-W')
          base_query = Week.where(year: year, number: number)
          concatenated_query = concatenated_query.nil? ? base_query : concatenated_query.or(base_query)
        end
        params[:weeks] = concatenated_query.all
      else
        params[:weeks] = Week.selectable_from_now_until_end_of_period
      end
      params
    end

    def assign_offer_to_current_api_user
      params[:employer] = user
      params
    end
  end
end
