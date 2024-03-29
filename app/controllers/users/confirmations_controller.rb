# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController

    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if confirmed_or_already_confirmed?(resource)
        set_flash_message!(:notice, :confirmed)
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
      end
    end


    protected

    def confirmed_or_already_confirmed?(resource)
      return true if resource.errors.empty?
      email_error = resource.errors.details.dig(:email, 0, :error)
      email_error == :already_confirmed
    end

    # The path used after sign up for inactive accounts.
    def after_confirmation_path_for(resource_name, resource)
      new_user_session_path(email: resource.email)
    end
  end
end
