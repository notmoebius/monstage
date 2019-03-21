class EmployerMailer < ApplicationMailer
  def new_internship_application_email
    @internship_application = params[:internship_application]

    mail(to: @internship_application.internship_offer.employer.email,
         subject: "Nouvelle candidature au stage #{@internship_application.internship_offer.title}")
  end
end
