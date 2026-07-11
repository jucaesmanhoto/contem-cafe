# Importa um arquivo de leitura de torrador para um Batch: atualiza os campos
# de resumo da torra e substitui os BatchDatum pela série temporal do arquivo.
class RoastFileImporter
  InvalidFileError = RoastFileParser::InvalidFileError

  def initialize(batch:, file:)
    @batch = batch
    @file = file
  end

  def call
    parsed = RoastFileParser.new(file.read).parse

    ActiveRecord::Base.transaction do
      batch.update!(parsed.batch_attributes)
      batch.batch_data.delete_all
      batch.batch_data.insert_all!(parsed.batch_data_rows, record_timestamps: true)
    end

    batch
  end

  private

  attr_reader :batch, :file
end
