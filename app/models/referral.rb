class Referral < ApplicationRecord
  DEFAULT_INITIAL_DISCOUNT_PERCENTAGE = 5.0
  DEFAULT_DISCOUNT_PERCENTAGE_PER_LEVEL = 2.5
  DEFAULT_MAX_DISCOUNT_PERCENTAGE = 20.0

  belongs_to :referrer, class_name: "Referral", optional: true
  has_many :referred_referrals, class_name: "Referral", foreign_key: :referrer_id, dependent: :nullify

  validates :name, presence: true
  validates :phone, presence: true
  validates :token, presence: true, uniqueness: true
  validates :initial_discount_percentage, :discount_percentage_per_level, :max_discount_percentage,
            numericality: { greater_than_or_equal_to: 0 }
  validate :phone_not_already_in_chain, on: :create

  before_validation :set_token, :set_depth, :set_discount_settings, on: :create

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
    growth = depth * discount_percentage_per_level.to_f
    [initial_discount_percentage.to_f + growth, max_discount_percentage.to_f].min
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
    self.depth = referrer ? referrer.depth.to_i + 1 : 0
  end

  def set_discount_settings
    self.initial_discount_percentage ||= inherited_or_default(:initial_discount_percentage,
                                                              DEFAULT_INITIAL_DISCOUNT_PERCENTAGE)
    self.discount_percentage_per_level ||= inherited_or_default(:discount_percentage_per_level,
                                                                DEFAULT_DISCOUNT_PERCENTAGE_PER_LEVEL)
    self.max_discount_percentage ||= inherited_or_default(:max_discount_percentage, DEFAULT_MAX_DISCOUNT_PERCENTAGE)
  end

  def inherited_or_default(attribute, default)
    referrer&.public_send(attribute) || default
  end

  # A person can't invite themselves back into their own upline.
  def phone_not_already_in_chain
    return unless referrer

    upline_phones = referrer.chain.map { |referral| normalize_phone(referral.phone) }
    return unless upline_phones.include?(normalize_phone(phone))

    errors.add(:base, "Você já faz parte desta indicação e não pode se indicar")
  end

  def normalize_phone(value)
    value.to_s.gsub(/\D/, "")
  end
end
