class FarmsController < ApplicationController
  # Allow public access to farm pages used by QR codes
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @farm = Farm.find_by(slug: params[:id]) || Farm.find(params[:id])
  end
end
