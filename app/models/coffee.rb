class Coffee < ApplicationRecord
  belongs_to :farm
  has_one_attached :photo

  validates :name, :variety, :processing, :altitude, presence: true
  before_validation :set_slug, :set_stock_status, on: :create

  def to_param
    slug.presence || id.to_s
  end

  private

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end

  def set_stock_status
    self.stock_status = "Esgotado" if stock_status.blank? && name.present?
  end
end
