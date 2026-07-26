class Avo::Resources::Referral < Avo::BaseResource
  def fields
    initial_discount_help = "Se em branco ao criar, herda do indicado-por (referrer) ou usa o padrão. " \
                            "Editar aqui não afeta indicações já criadas a partir deste registro."

    field :id, as: :id
    field :name, as: :text
    field :phone, as: :text
    field :token, as: :text, readonly: true
    field :depth, as: :number, readonly: true
    field :initial_discount_percentage, as: :number, step: 0.01, help: initial_discount_help
    field :discount_percentage_per_level, as: :number, step: 0.01
    field :max_discount_percentage, as: :number, step: 0.01
    field :referrer, as: :belongs_to
    field :referred_referrals, as: :has_many
  end
end
