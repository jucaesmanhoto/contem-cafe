class CoffeesController < ApplicationController
  # Allow public access to coffee pages linked from farm QR pages and to the catalog
  skip_before_action :authenticate_user!, only: %i[index show]

  # Catálogo público (/catalog): cafés disponíveis, agrupados pela ordem das fazendas
  def index
    @coffees = Coffee.availables
                     .joins(:farm)
                     .includes(:farm, photo_attachment: :blob)
                     .order("farms.position", "farms.name", :name)
  end

  def show
    @coffee = Coffee.find_by(slug: params[:id]) || Coffee.find(params[:id])
  end

  def new
    @coffee = Coffee.new
  end

  def create
    raise
  end
end
