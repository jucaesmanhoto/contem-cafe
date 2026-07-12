# Converte os valores de evento/data do formato KLDO (ex: "150@03:28", "10:30")
# em valores Ruby usados pelo RoastFileParser.
module RoastEventValueParser
  module_function

  def cook_date(value)
    raise RoastFileParser::InvalidFileError, "CookDate não encontrado no arquivo" if value.blank?

    DateTime.strptime(value, "%d-%m-%y %H:%M:%S")
  rescue ArgumentError
    raise RoastFileParser::InvalidFileError, "CookDate em formato inesperado: \"#{value}\""
  end

  # "09-04-26 17:08:29" -> "2604091708" (ano, mês, dia, hora, minuto — todos com 2 dígitos)
  def batch_number(cook_date)
    cook_date.strftime("%y%m%d%H%M")
  end

  # "150@03:28" -> [150, 208]
  def event(value)
    return [nil, nil] if value.blank?

    temperature, time = value.split("@")
    [temperature.to_i, duration(time)]
  end

  # "10:30" -> 630
  def duration(value)
    return nil if value.blank?

    minutes, seconds = value.split(":").map(&:to_i)
    (minutes * 60) + seconds
  end
end
