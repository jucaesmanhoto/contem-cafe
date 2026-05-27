# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/3.0/controllers.html
class Avo::CoffeesController < Avo::ResourcesController
  def create
    raise
    permited_params[:farm_id] = Farm.find_by(slug: params[:farm_id]).id
    @coffee = Coffee.new(permited_params)
    if @coffee.save
      redirect_to :ressources_coffees_path
    else
      raise
    end
  end

  private

  def permited_params
    params.require(:coffee).permit(:name, :description, :variety, :processing, :altitude, :farm_id, :species, :price, :slug, :stock_status)
  end
end
