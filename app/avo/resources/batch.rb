class Avo::Resources::Batch < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  # Batch#to_param usa batch_number (não o id numérico) nas URLs; batch_number
  # pode ser só dígitos, então não dá pra distinguir por regex, tenta achar primeiro
  self.find_record_method = -> {
    query.find_by(batch_number: id) || query.find(id)
  }

  def fields
    field :id, as: :id
    field :coffee, as: :belongs_to
    field :batch_number, as: :text
    field :roast_end_time, as: :date_time
    field :total_time_in_seconds, as: :number
    field :start_celsius_temperature, as: :number
    field :turn_to_yellow_time_in_seconds, as: :number
    field :turn_to_yellow_celsius_temperature, as: :number
    field :first_crack_time_in_seconds, as: :number
    field :first_crack_celsius_temperature, as: :number
    field :initial_quantity_in_grams, as: :number
    field :final_quantity_in_grams, as: :number
    field :color_in_agtron, as: :number
  end

  def actions
    action Avo::Actions::ImportRoastData
  end
end
