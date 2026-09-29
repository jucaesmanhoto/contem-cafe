require "test_helper"

class CoffeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @farm = Farm.create!(name: "Fazenda Jangada", city: "Carmo de Minas", state: "MG")
  end

  def create_coffee(name, stock_status:, price: nil)
    Coffee.create!(farm: @farm, name: name, variety: "Catuaí", processing: "Natural",
                   altitude: 1150, stock_status: stock_status, price: price)
  end

  test "catalog renders without authentication" do
    get catalog_path
    assert_response :success
  end

  test "catalog lists available coffees with price and link, and hides sold-out ones" do
    available = create_coffee("JG22", stock_status: "disponível", price: 5800)
    create_coffee("Castanhas", stock_status: "Esgotado")

    get catalog_path

    assert_select ".musa-coffee-card", count: 1
    assert_select "a.musa-coffee-card[href=?]", farm_coffee_path(@farm, available)
    assert_select ".musa-coffee-name", text: "JG22"
    assert_select ".musa-coffee-price", text: /R\$58,00/
    assert_select ".musa-coffee-v", text: "1.150 m"
    assert_no_match "Castanhas", response.body
  end

  test "catalog shows an empty state when every coffee is sold out" do
    create_coffee("Castanhas", stock_status: "Esgotado")

    get catalog_path

    assert_select ".musa-coffee-card", count: 0
    assert_select ".musa-section-intro", text: /esgotados/
  end
end
