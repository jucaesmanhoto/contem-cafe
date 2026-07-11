module Api
  class BaseController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    before_action :authenticate_api_key!

    private

    def authenticate_api_key!
      return if ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(provided_api_key),
        Digest::SHA256.hexdigest(expected_api_key)
      )

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def provided_api_key
      request.headers["X-API-Key"].to_s
    end

    def expected_api_key
      ENV.fetch("ROAST_UPLOAD_API_KEY")
    end
  end
end
