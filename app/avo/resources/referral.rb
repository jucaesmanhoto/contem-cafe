class Avo::Resources::Referral < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :phone, as: :text
    field :token, as: :text, readonly: true
    field :depth, as: :number, readonly: true
    field :referrer, as: :belongs_to
    field :referred_referrals, as: :has_many
  end
end
