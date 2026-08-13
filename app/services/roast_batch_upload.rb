# Recebe um arquivo de leitura de torrador e resolve o Batch alvo: modo
# estrito (batch_number/id de uma torra existente) ou auto-criação
# (coffee_id, usando o batch_number lido do próprio arquivo). Usado tanto
# pela API (Api::V1::BatchDataController) quanto pela página de upload
# (BatchUploadsController).
class RoastBatchUpload
  InvalidFileError = RoastFileParser::InvalidFileError

  Result = Struct.new(:batch, :error) do
    def success?
      error.nil?
    end
  end

  def initialize(file:, batch_number: nil, coffee_id: nil)
    @file = file
    @batch_number = batch_number
    @coffee_id = coffee_id
  end

  def call
    return Result.new(nil, "Arquivo não enviado") if file.blank?

    batch, coffee, error = resolve_target
    return Result.new(nil, error) if error

    Result.new(RoastFileImporter.new(batch: batch, coffee: coffee, file: file).call, nil)
  rescue InvalidFileError => e
    Result.new(nil, e.message)
  end

  private

  attr_reader :file, :batch_number, :coffee_id

  def resolve_target
    return resolve_by_identifier if batch_number.present?

    resolve_by_coffee
  end

  def resolve_by_identifier
    batch = Batch.find_by(batch_number: batch_number) || Batch.find_by(id: batch_number)
    return [nil, nil, "Torra não encontrada"] if batch.nil?

    [batch, nil, nil]
  end

  def resolve_by_coffee
    no_target_msg = "Informe batch_number (torra existente) ou coffee_id (para criar uma nova)"
    return [nil, nil, no_target_msg] if coffee_id.blank?

    coffee = Coffee.find_by(slug: coffee_id) || Coffee.find_by(id: coffee_id)
    return [nil, nil, "Café não encontrado"] if coffee.nil?

    [nil, coffee, nil]
  end
end
