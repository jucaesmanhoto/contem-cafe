# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/3.0/controllers.html
module Avo
  class CoffeesController < Avo::ResourcesController
    def create
      coffee_params = permited_params
      coffee_params[:farm_id] = Farm.find_by(slug: coffee_params[:farm_id])&.id
      @coffee = Coffee.new(coffee_params)
      raise unless @coffee.save

      redirect_to :resources_coffees_path
    end

    private

    def permited_params
      params.require(:coffee).permit(:name, :description, :variety, :processing, :altitude, :farm_id, :species, :price,
                                     :slug, :stock_status)
    end
  end
end
