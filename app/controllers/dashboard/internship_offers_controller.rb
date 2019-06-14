# frozen_string_literal: true

module Dashboard
  class InternshipOffersController < ApplicationController
    include SetInternshipOffers

    before_action :authenticate_user!

    def index
      set_internship_offers
      @internship_offers = @internship_offers.order(convention_signed_applications_count: :desc,
                                                    total_applications_count: :desc,
                                                    updated_at: :desc)
    end

    def show
      @internship_offer = InternshipOffer.find(params[:id])
    end

    def create
      internship_offer_builder.create({params: method(:internship_offer_params)}) do |on|
        on.success do |created_internship_offer|
          redirect_to(dashboard_internship_offer_path(created_internship_offer),
                      flash: { success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier. Nous vous remercions vivement pour votre participation à cette dynamique nationale.' })
        end
        on.failure do |failed_internship_offer|
          @internship_offer = failed_internship_offer || InternshipOffer.new
          find_selectable_weeks
          render :new, status: :bad_request
        end
      end
    end

    def edit
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :update, @internship_offer
      find_selectable_weeks
    end

    def update
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :update, @internship_offer
      @internship_offer.update!(internship_offer_params)
      redirect_to(@internship_offer,
                  flash: { success: 'Votre annonce a bien été modifiée' })
    rescue ActiveRecord::RecordInvalid,
           ActionController::ParameterMissing => e
      find_selectable_weeks
      render :edit, status: :bad_request
    end

    def destroy
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :discard, @internship_offer
      @internship_offer.discard
      redirect_to(dashboard_internship_offers_path,
                  flash: { success: 'Votre annonce a bien été supprimée' })
    end

    def new
      authorize! :create, InternshipOffer
      @internship_offer = InternshipOffer.new
      find_selectable_weeks
    end

    private

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user)
    end

    def internship_offer_params
      params.require(:internship_offer)
            .permit(:title, :description, :sector_id, :max_candidates, :max_internship_week_number,
                    :tutor_name, :tutor_phone, :tutor_email, :employer_website, :employer_name,
                    :street, :zipcode, :city, :department, :region, :academy,
                    :is_public, :group,
                    :employer_id, :employer_type, :school_id, :employer_description,
                    operator_ids: [], coordinates: {}, week_ids: [])
    end
  end
end
