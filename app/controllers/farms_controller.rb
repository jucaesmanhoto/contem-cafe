class FarmsController < ApplicationController
  def show
    @farm = Farm.find_by(slug: params[:id]) || Farm.find(params[:id])
  end
end
