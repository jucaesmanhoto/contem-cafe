module ReferralsHelper
  def whatsapp_share_url(referral)
    message = "Entra na corrente de indicação da Musa Cafés e ganhe desconto! #{referral_url(referral.token)}"
    "https://wa.me/?text=#{ERB::Util.url_encode(message)}"
  end

  def admin_whatsapp_number
    ENV.fetch("ADMIN_WHATSAPP_NUMBER", "5541999479117")
  end

  def admin_whatsapp_url(message)
    "https://wa.me/#{admin_whatsapp_number}?text=#{ERB::Util.url_encode(message)}"
  end

  def coffee_price_label(coffee)
    return nil unless coffee.price.present?

    number_to_currency(coffee.price / 100.0, unit: "R$", separator: ",", delimiter: ".")
  end

  def coffee_discounted_price_label(coffee, discount_percentage)
    return nil unless coffee.price.present?

    discounted_amount = coffee.price / 100.0 * (1 - (discount_percentage / 100.0))
    number_to_currency(discounted_amount, unit: "R$", separator: ",", delimiter: ".")
  end
end
