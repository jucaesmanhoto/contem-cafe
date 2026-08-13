require "test_helper"

module Api
  module V1
    class BatchDataControllerTest < ActionDispatch::IntegrationTest
      setup do
        @farm = Farm.create!(name: "Fazenda Teste", city: "Cidade Teste")
        @coffee = Coffee.create!(
          farm: @farm, name: "Café Teste", variety: "Bourbon", processing: "Natural", altitude: 1200
        )
        @batchone = Batch.create!(coffee: @coffee, batch_number: "PENDING-1")
        @batchtwo = Batch.create!(coffee: @coffee)
        @headers = { "X-API-Key" => ENV.fetch("ROAST_UPLOAD_API_KEY") }
      end

      test "imports multiple files in a single request, matching batches by batch_number and id" do
        assert_difference "BatchDatum.count", 4 do
          post api_v1_batches_upload_path, params: {
            batch_data: [
              { batch_number: @batchone.batch_number, file: roast_file("roast_batch_1.txt") },
              { batch_number: @batchtwo.id, file: roast_file("roast_batch_2.txt") }
            ]
          }, headers: @headers
        end

        assert_response :success
        results = JSON.parse(response.body)["results"]

        assert_equal 2, results.size
        assert_equal "2604091708", results[0]["batch_number"]
        assert_equal "importado", results[0]["status"]
        assert_equal "2604100915", results[1]["batch_number"]
        assert_equal "importado", results[1]["status"]

        assert_equal "2604091708", @batchone.reload.batch_number
        assert_equal "2604100915", @batchtwo.reload.batch_number
      end

      test "reports a per-file error without failing the whole request" do
        assert_difference "BatchDatum.count", 2 do
          post api_v1_batches_upload_path, params: {
            batch_data: [
              { batch_number: @batchone.batch_number, file: roast_file("roast_batch_1.txt") },
              { batch_number: @batchtwo.id, file: roast_file("invalid_roast.txt") },
              { batch_number: "não-existe", file: roast_file("roast_batch_2.txt") }
            ]
          }, headers: @headers
        end

        assert_response :unprocessable_entity
        results = JSON.parse(response.body)["results"]

        assert_equal "importado", results[0]["status"]
        assert results[1]["error"].present?
        assert_equal "Torra não encontrada", results[2]["error"]
      end

      test "returns bad_request when no files are sent" do
        post api_v1_batches_upload_path, params: {}, headers: @headers
        assert_response :bad_request
      end

      test "creates a new batch for the given coffee when no batch_number matches" do
        assert_difference -> { Batch.count } => 1, -> { BatchDatum.count } => 2 do
          post api_v1_batches_upload_path, params: {
            batch_data: [{ coffee_id: @coffee.id, file: roast_file("roast_batch_1.txt") }]
          }, headers: @headers
        end

        assert_response :success
        result = JSON.parse(response.body)["results"].first
        assert_equal "2604091708", result["batch_number"]
        assert_equal "importado", result["status"]

        created_batch = Batch.find_by(batch_number: "2604091708")
        assert_equal @coffee, created_batch.coffee
      end

      test "reuses an existing batch matching the batch_number parsed from the file" do
        existing = Batch.create!(coffee: @coffee, batch_number: "2604091708")

        assert_no_difference "Batch.count" do
          post api_v1_batches_upload_path, params: {
            batch_data: [{ coffee_id: @coffee.id, file: roast_file("roast_batch_1.txt") }]
          }, headers: @headers
        end

        assert_response :success
        assert_equal 2, existing.reload.batch_data.count
      end

      test "errors when neither batch_number nor coffee_id are informed" do
        post api_v1_batches_upload_path, params: {
          batch_data: [{ file: roast_file("roast_batch_1.txt") }]
        }, headers: @headers

        assert_response :unprocessable_entity
        result = JSON.parse(response.body)["results"].first
        assert_equal "Informe batch_number (torra existente) ou coffee_id (para criar uma nova)", result["error"]
      end

      test "errors when coffee_id does not match any coffee" do
        post api_v1_batches_upload_path, params: {
          batch_data: [{ coffee_id: 0, file: roast_file("roast_batch_1.txt") }]
        }, headers: @headers

        assert_response :unprocessable_entity
        result = JSON.parse(response.body)["results"].first
        assert_equal "Café não encontrado", result["error"]
      end

      test "requires a valid api key" do
        post api_v1_batches_upload_path, params: {
          batch_data: [{ batch_number: @batchone.batch_number, file: roast_file("roast_batch_1.txt") }]
        }
        assert_response :unauthorized
      end

      private

      def roast_file(name)
        fixture_file_upload(file_fixture(name), "text/plain")
      end
    end
  end
end
