module Api
  module V1
    class BatchDataController < Api::BaseController
      def create
        file = params[:file]

        return render json: { error: "Arquivo não enviado" }, status: :bad_request if file.blank?

        render json: {
          batch_number: params[:batch_number],
          filename: file.original_filename,
          content_type: file.content_type,
          size: file.size,
          preview: file.read(500)
        }
      end
    end
  end
end
