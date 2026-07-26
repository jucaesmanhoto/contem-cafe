class ReferralsController < ApplicationController
  # Allow public access: visitors arrive here only via someone else's referral link
  skip_before_action :authenticate_user!, only: %i[show create success]

  def show
    @referral = Referral.find_by!(token: params[:token])
    @chain = @referral.chain
    @new_referral = Referral.new
    @coffees = Coffee.order(:name)
  end

  def create
    referrer = Referral.find_by(token: params[:referrer_token])
    return redirect_to root_path, alert: "Link de indicação inválido." if referrer.nil?

    @new_referral = Referral.new(referral_params.merge(referrer: referrer))

    if @new_referral.save
      redirect_to success_referral_path(@new_referral.token)
    else
      load_show_locals(referrer)
      render :show, status: :unprocessable_entity
    end
  end

  def success
    @referral = Referral.find_by!(token: params[:token])
    @chain = @referral.chain
  end

  private

  def load_show_locals(referral)
    @referral = referral
    @chain = referral.chain
    @coffees = Coffee.order(:name)
  end

  def referral_params
    params.permit(:name, :phone)
  end
end
