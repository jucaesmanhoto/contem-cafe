class Batch < ApplicationRecord
  belongs_to :coffee
  has_many :batch_data, dependent: :destroy, inverse_of: :batch

  def to_param
    batch_number.presence || id.to_s
  end
end
