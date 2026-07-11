class BatchesController < ApplicationController
  # Allow public access to the roast lookup page
  skip_before_action :authenticate_user!, only: [:index]

  def index
    return if params[:batch_number].blank?

    @batch = Batch.includes(:coffee).find_by(batch_number: params[:batch_number])

    if @batch
      @batch_data = @batch.batch_data.order(:time_in_milliseconds)
    else
      flash.now[:alert] = "Nenhuma torra encontrada com o número de batch \"#{params[:batch_number]}\"."
    end
  end
end
