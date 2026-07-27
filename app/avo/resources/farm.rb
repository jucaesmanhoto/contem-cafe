module Avo
  module Resources
    class Farm < Avo::BaseResource
      # self.includes = []
      # self.attachments = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
      # }

      # Farm#to_param usa slug (não o id numérico) nas URLs
      self.find_record_method = lambda {
        query.find_by(slug: id) || query.find(id)
      }

      def fields
        field :id, as: :id
        field :name, as: :text
        field :description, as: :textarea
        field :slug, as: :text
        field :farmer, as: :text
        field :city, as: :text
        field :state, as: :text
        field :region, as: :text
        field :photo, as: :file
        field :coffees, as: :has_many
      end
    end
  end
end
