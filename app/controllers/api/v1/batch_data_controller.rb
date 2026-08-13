module Api
  module V1
    class BatchDataController < Api::BaseController
      # Importa uma ou mais leituras de torrador (formato KLDO). Cada item de
      # batch_data traz o arquivo e, opcionalmente, o batch_number/id de uma
      # torra já existente (modo estrito) ou o coffee_id da coffee para a qual
      # criar uma nova torra automaticamente, usando o batch_number lido do
      # próprio arquivo (CookDate). Um item inválido não impede os demais.
      def create
        uploads = extract_uploads(params[:batch_data])

        return render json: { error: "Nenhum arquivo enviado" }, status: :bad_request if uploads.blank?

        results = uploads.map { |upload| import_upload(upload) }
        status = results.any? { |result| result[:error] } ? :unprocessable_entity : :ok

        render json: { results: results }, status: status
      end

      private

      # Multipart com índices explícitos (batch_data[0][file], batch_data[1][file], ...)
      # chega como um Hash de índice => item, não como Array — daí o .values aqui.
      def extract_uploads(raw)
        return [] if raw.blank?

        raw.respond_to?(:values) ? raw.values : Array(raw)
      end

      def import_upload(upload)
        result = RoastBatchUpload.new(
          file: upload[:file],
          batch_number: upload[:batch_number],
          coffee_id: upload[:coffee_id]
        ).call

        return { batch_number: upload[:batch_number], error: result.error } unless result.success?

        { batch_number: result.batch.batch_number, status: "importado" }
      end
    end
  end
end
