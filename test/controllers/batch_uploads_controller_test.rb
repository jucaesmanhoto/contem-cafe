require "test_helper"

class BatchUploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @farm = Farm.create!(name: "Fazenda Teste", city: "Cidade Teste")
    @coffee = Coffee.create!(
      farm: @farm, name: "Café Teste", variety: "Bourbon", processing: "Natural", altitude: 1200
    )
    @admin = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    @regular_user = User.create!(email: "user@example.com", password: "password123", role: :user)
  end

  test "redirects unauthenticated visitors to login" do
    get new_batch_upload_path
    assert_redirected_to new_user_session_path
  end

  test "redirects non-admin users" do
    sign_in @regular_user
    get new_batch_upload_path
    assert_redirected_to root_path
  end

  test "allows admin to view the upload form" do
    sign_in @admin
    get new_batch_upload_path
    assert_response :success
  end

  test "admin uploads multiple files, gets redirected with a success flash and sees per-file results" do
    sign_in @admin

    assert_difference "Batch.count", 2 do
      post batch_upload_path, params: {
        coffee_id: @coffee.id,
        files: [roast_file("roast_batch_1.txt"), roast_file("roast_batch_2.txt")]
      }
    end

    assert_redirected_to new_batch_upload_path
    assert_equal "2 arquivo(s) importado(s) com sucesso.", flash[:notice]

    follow_redirect!
    assert_response :success
    assert_select "li", text: /Importado — batch 2604091708/
    assert_select "li", text: /Importado — batch 2604100915/
  end

  test "redirects with an alert summarizing per-file errors without failing the whole request" do
    sign_in @admin

    assert_difference "Batch.count", 1 do
      post batch_upload_path, params: {
        coffee_id: @coffee.id,
        files: [roast_file("roast_batch_1.txt"), roast_file("invalid_roast.txt")]
      }
    end

    assert_redirected_to new_batch_upload_path
    assert_equal "1 de 2 arquivo(s) importado(s); 1 com erro (veja os detalhes abaixo).", flash[:alert]
  end

  test "redirects with an alert when no files are sent" do
    sign_in @admin
    post batch_upload_path, params: { coffee_id: @coffee.id }
    assert_redirected_to new_batch_upload_path
    assert_equal "Selecione ao menos um arquivo.", flash[:alert]
  end

  test "shows an error for a non-admin trying to create via create action" do
    sign_in @regular_user
    post batch_upload_path, params: { coffee_id: @coffee.id, files: [roast_file("roast_batch_1.txt")] }
    assert_redirected_to root_path
  end

  private

  def roast_file(name)
    fixture_file_upload(file_fixture(name), "text/plain")
  end
end
