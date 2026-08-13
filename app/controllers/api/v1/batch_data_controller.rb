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
        file = upload[:file]
        identifier = upload[:batch_number]
        return { batch_number: identifier, error: "Arquivo não enviado" } if file.blank?

        batch, coffee, error = resolve_target(identifier, upload[:coffee_id])
        return { batch_number: identifier, error: error } if error

        result = RoastFileImporter.new(batch: batch, coffee: coffee, file: file).call
        { batch_number: result.batch_number, status: "importado" }
      rescue RoastFileParser::InvalidFileError => e
        { batch_number: identifier, error: e.message }
      end

      # Modo estrito (batch_number/id de uma torra existente) ou auto-criação
      # (coffee_id) — ver comentário de #create.
      def resolve_target(identifier, coffee_id)
        return resolve_by_identifier(identifier) if identifier.present?

        resolve_by_coffee(coffee_id)
      end

      def resolve_by_identifier(identifier)
        batch = find_batch(identifier)
        return [nil, nil, "Torra não encontrada"] if batch.nil?

        [batch, nil, nil]
      end

      def resolve_by_coffee(coffee_id)
        no_target_msg = "Informe batch_number (torra existente) ou coffee_id (para criar uma nova)"
        return [nil, nil, no_target_msg] if coffee_id.blank?

        coffee = find_coffee(coffee_id)
        return [nil, nil, "Café não encontrado"] if coffee.nil?

        [nil, coffee, nil]
      end

      def find_batch(identifier)
        Batch.find_by(batch_number: identifier) || Batch.find_by(id: identifier)
      end

      def find_coffee(identifier)
        Coffee.find_by(slug: identifier) || Coffee.find_by(id: identifier)
      end
    end
  end
end
