class PagesController < ApplicationController
  # Permite que usuários não logados acessem a home page
  skip_before_action :authenticate_user!, only: [ :home, :satisfaction_survey, :satisfaction_thanks, :about_coffee ], raise: false

  def home
  end

  def satisfaction_survey
    @tally_form_url = ENV.fetch("TALLY_SATISFACTION_FORM_URL", "")
    @survey_thank_you_url = "#{request.base_url}#{satisfaction_thanks_path}"
  end

  def satisfaction_thanks
  end

  def about_coffee
  end
end
