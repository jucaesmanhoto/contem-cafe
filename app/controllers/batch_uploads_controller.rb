class BatchUploadsController < ApplicationController
  before_action :require_admin!
  before_action :set_coffees

  def new
    @results = flash[:batch_upload_results]
  end

  # rubocop:disable Metrics/MethodLength
  def create
    files = Array(params[:files]).select(&:present?)

    return redirect_to new_batch_upload_path, alert: "Selecione ao menos um arquivo." if files.blank?

    results = files.map { |file| import_result(file) }
    error_count = results.count { |result| !result["success"] }
    flash[:batch_upload_results] = results

    if error_count.zero?
      redirect_to new_batch_upload_path, notice: "#{results.size} arquivo(s) importado(s) com sucesso."
    else
      redirect_to new_batch_upload_path,
                  alert: "#{results.size - error_count} de #{results.size} arquivo(s) importado(s); " \
                         "#{error_count} com erro (veja os detalhes abaixo)."
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def import_result(file)
    result = RoastBatchUpload.new(file: file, coffee_id: params[:coffee_id]).call

    if result.success?
      { "filename" => file.original_filename, "success" => true,
        "message" => "Importado — batch #{result.batch.batch_number}" }
    else
      { "filename" => file.original_filename, "success" => false, "message" => result.error }
    end
  end

  def set_coffees
    @coffees = Coffee.includes(:farm).order(:name)
  end
end
