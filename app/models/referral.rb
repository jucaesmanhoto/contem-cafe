class Referral < ApplicationRecord
  belongs_to :referrer, class_name: "Referral", optional: true
  has_many :referred_referrals, class_name: "Referral", foreign_key: :referrer_id, dependent: :nullify

  validates :name, presence: true
  validates :phone, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :set_token, :set_depth, on: :create

  def ancestors
    chain = []
    node = referrer
    while node
      chain << node
      node = node.referrer
    end
    chain
  end

  # Full chain from the root down to (and including) this referral, for display.
  def chain
    ([self] + ancestors).reverse
  end

  def root?
    referrer_id.nil?
  end

  # Discount shown to whoever joins through this referral's link — grows with
  # how deep this referral sits in its chain, capped so it can't run away.
  def discount_percentage
    [depth * self.class.discount_percentage_per_level, self.class.max_discount_percentage].min
  end

  def self.discount_percentage_per_level
    ENV.fetch("REFERRAL_DISCOUNT_PERCENTAGE_PER_LEVEL", "2.5").to_f
  end

  def self.max_discount_percentage
    ENV.fetch("REFERRAL_MAX_DISCOUNT_PERCENTAGE", "20.0").to_f
  end

  # Depth assigned to a chain's root (a referral with no referrer). Configurable
  # so the very first invite of a chain doesn't have to start at 0% discount.
  def self.root_depth
    ENV.fetch("REFERRAL_ROOT_DEPTH", "0").to_i
  end

  private

  def set_token
    return if token.present?

    loop do
      candidate = SecureRandom.hex(8)
      next if self.class.exists?(token: candidate)

      self.token = candidate
      break
    end
  end

  def set_depth
    return unless depth.nil?

    self.depth = referrer ? referrer.depth.to_i + 1 : self.class.root_depth
  end
end
