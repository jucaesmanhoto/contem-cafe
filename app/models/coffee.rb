class Coffee < ApplicationRecord
  belongs_to :farm

  validates :name, :variety, :processing, :altitude, presence: true
end
