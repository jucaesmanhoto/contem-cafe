class PagesController < ApplicationController
  # Permite que usuários não logados acessem a home page
  skip_before_action :authenticate_user!, only: [ :home, :try_form, :satisfaction_survey, :satisfaction_thanks, :about_coffee ], raise: false

  def home
    set_payment_link
  end

  def try_form
    @trial_form_url = "https://tally.so/r/MeJPzX"
  end

  def satisfaction_survey
    set_payment_link
    @tally_form_url = ENV.fetch("TALLY_SATISFACTION_FORM_URL", "")
    @survey_thank_you_url = "#{request.base_url}#{satisfaction_thanks_path}"
  end

  def satisfaction_thanks
    set_payment_link
  end

  def about_coffee
    set_payment_link
  end

  private

  def set_payment_link
    @payment_link = ENV.fetch("PAYMENT_LINK_URL", "")
  end
end
