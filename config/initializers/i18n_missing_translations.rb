# Em produção o usuário nunca deve ver "Translation missing: pt-BR.alguma.chave".
# Quando a chave não existe nem em pt-BR nem no fallback :en, devolvemos o
# último segmento humanizado ("signed_in" -> "Signed in") em vez da mensagem
# de erro crua. Em desenvolvimento/teste o texto cru continua aparecendo, que é
# como percebemos que falta traduzir algo.
#
# Só afeta chamadas diretas a I18n.t (flashes do Devise, mailers etc.);
# o helper `t` das views já tem o próprio tratamento (span .translation_missing).
if Rails.env.production?
  class HumanizeMissingTranslations < I18n::ExceptionHandler
    def call(exception, locale, key, options)
      return super unless exception.is_a?(I18n::MissingTranslation)

      Rails.logger.warn("[i18n] tradução ausente: #{locale}.#{key}")
      exception.key.to_s.split(".").last.to_s.humanize
    end
  end

  I18n.exception_handler = HumanizeMissingTranslations.new
end
