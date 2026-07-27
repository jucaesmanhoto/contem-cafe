module Avo
  module Actions
    class ImportRoastData < Avo::BaseAction
      self.name = "Importar leitura do torrador"

      def fields
        field :file, as: :file, required: true
      end

      def handle(query:, fields:, **_args)
        file = fields[:file]
        return error("Selecione um arquivo para importar.") if file.blank?

        batches = Array(query).map { |batch| RoastFileImporter.new(batch: batch, file: file).call }

        succeed("Leitura do torrador importada com sucesso.")
        # batch_number muda como efeito do import, então a URL atual (com o batch_number antigo) fica inválida
        redirect_to(avo.resources_batch_path(batches.first)) if batches.one?
      rescue RoastFileImporter::InvalidFileError => e
        error(e.message)
      end
    end
  end
end
