class CoffeesController < ApplicationController
  # Allow public access to coffee pages linked from farm QR pages
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @coffee = Coffee.find_by(slug: params[:id]) || Coffee.find(params[:id])
  end
end
