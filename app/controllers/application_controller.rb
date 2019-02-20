class ApplicationController < ActionController::Base
  delegate :current_user, to: :session_manager
  before_action :current_user

  private
  def session_manager
    @session_manager ||= SessionManager.new(request: request,
                                            session: session)
  end
end
