module Dashboard
  module InternshipOffers
    class InternshipApplicationsController < ApplicationController
      before_action :authenticate_user!
      before_action :find_internship_offer, only: [:index, :update]

      def index
        set_intership_applications
        authorize! :read, @internship_offer
        authorize! :index, InternshipApplication
      end

      def create
        @internship_application = InternshipApplication.new(internship_application_params)
        authorize! :apply, InternshipOffer
        @internship_application.save!
        EmployerMailer.with(internship_application: @internship_application).new_internship_application_email.deliver_later
        redirect_to internship_offers_path, flash: { success: "Votre candidature a bien été envoyée." }
      rescue ActiveRecord::RecordInvalid => error
        @internship_offer = InternshipOffer.find(params[:internship_offer_id])
        flash[:danger] = "Erreur dans la saisie de votre candidature"
        render "internship_offers/show", status: :bad_request
      end

      def update
        @internship_application = @internship_offer.internship_applications.find(params[:id])
        authorize! :update, @internship_offer, InternshipApplication
        @internship_application.send(params[:transition]) if valid_transition?
        redirect_to dashboard_internship_offer_internship_applications_path(@internship_application.internship_offer),
                    flash: { success: 'Candidature mis à jour avec succès' }
      rescue AASM::InvalidTransition => e
        redirect_to dashboard_internship_offer_internship_applications_path(@internship_application.internship_offer),
                    flash: { warning: 'Cette candidature a déjà été traitée' }

      end

      private

      def valid_transition?
        %w[approve! reject! signed! cancel!].include?(params[:transition])
      end

      def set_intership_applications
        @internship_applications = @internship_offer.internship_applications
                                                    .order(updated_at: :desc)
                                                    .page(params[:page])
      end

      def find_internship_offer
        @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      end

      def internship_application_params
        params.require(:internship_application).permit(:motivation, :internship_offer_week_id, :user_id)
      end
    end
  end
end
