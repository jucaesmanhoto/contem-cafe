module Avo
  module Resources
    class Coffee < Avo::BaseResource
      # self.includes = []
      # self.attachments = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
      # }

      # Coffee#to_param usa slug (não o id numérico) nas URLs
      self.find_record_method = lambda {
        query.find_by(slug: id) || query.find(id)
      }

      # rubocop:disable Metrics/MethodLength
      def fields
        field :id, as: :id
        field :name, as: :text
        field :description, as: :textarea
        field :variety, as: :text
        field :processing, as: :text
        field :altitude, as: :number
        field :farm_id, as: :number
        field :species, as: :text
        field :price, as: :number
        field :slug, as: :text
        field :stock_status, as: :text
        field :photo, as: :file
        field :farm, as: :belongs_to
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
