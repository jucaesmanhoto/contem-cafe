class Farm < ApplicationRecord
  has_many :coffees, dependent: :destroy
  has_one_attached :photo

  validates :name, :city, presence: true
  validates :state, length: {is: 2}, allow_blank: true
  before_validation :set_slug, on: :create

  def to_param
    slug.presence || id.to_s
  end

  private

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
