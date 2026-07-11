class Avo::Resources::BatchDatum < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :time_in_milliseconds, as: :number
    field :bean_temperature_in_celsius, as: :number
    field :exaust_temperature_in_celsius, as: :number
    field :ror, as: :number
    field :power, as: :number
    field :air_flow, as: :number
    field :drum_rotation, as: :number
    field :batch, as: :belongs_to
  end
end
