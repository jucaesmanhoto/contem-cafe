# Importa um arquivo de leitura de torrador para um Batch: atualiza os campos
# de resumo da torra e substitui os BatchDatum pela série temporal do arquivo.
# Se nenhum batch for informado, procura um já existente com o batch_number
# lido do arquivo (CookDate) e, não encontrando, cria um novo para a coffee informada.
class RoastFileImporter
  InvalidFileError = RoastFileParser::InvalidFileError

  def initialize(file:, batch: nil, coffee: nil)
    @batch = batch
    @coffee = coffee
    @file = file
  end

  def call
    parsed = RoastFileParser.new(file.read).parse
    target = batch || find_or_build_batch(parsed.batch_attributes[:batch_number])

    ActiveRecord::Base.transaction do
      target.update!(parsed.batch_attributes)
      target.batch_data.delete_all
      target.batch_data.insert_all!(parsed.batch_data_rows, record_timestamps: true)
    end

    target
  end

  private

  attr_reader :batch, :coffee, :file

  def find_or_build_batch(batch_number)
    Batch.find_by(batch_number: batch_number) || build_batch(coffee)
  end

  def build_batch(coffee)
    if coffee.nil?
      raise InvalidFileError,
            "Nenhuma torra existente para este arquivo; informe a coffee para criar uma nova"
    end

    Batch.new(coffee: coffee)
  end
end
