class BatchesController < ApplicationController
  # Allow public access to the roast lookup page
  skip_before_action :authenticate_user!, only: [:index]

  def index
    return if params[:roast_date].blank? || params[:roast_time].blank?

    cook_date = parse_cook_date(params[:roast_date], params[:roast_time])

    if cook_date.nil?
      flash.now[:alert] = "Data ou horário inválidos."
      return
    end

    @batch = Batch.includes(:coffee).find_by(batch_number: RoastEventValueParser.batch_number(cook_date))

    if @batch
      @batch_data = @batch.batch_data.order(:time_in_milliseconds)
    else
      flash.now[:alert] = "Nenhuma torra encontrada para #{cook_date.strftime('%d.%m')} - #{cook_date.strftime('%H:%M')}."
    end
  end

  private

  def parse_cook_date(date, time)
    DateTime.strptime("#{date} #{time}", "%Y-%m-%d %H:%M")
  rescue ArgumentError, TypeError
    nil
  end
end
