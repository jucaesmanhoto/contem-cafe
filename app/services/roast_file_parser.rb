require "csv"

# Faz o parsing de um arquivo de leitura de torrador (formato KLDO):
# separa a seção de metadados da torra da seção [{DATA}] com a série temporal.
# rubocop:disable Metrics/ClassLength
class RoastFileParser
  class InvalidFileError < StandardError; end

  EXPECTED_HEADER = "KLDO data file V101"
  DATA_SECTION_MARKER = "[{DATA}]"
  SECTION_KEY_REGEX = /\A\[\{(\w+)\}\]\z/

  Result = Struct.new(:batch_attributes, :batch_data_rows)

  def initialize(content)
    @content = content
  end

  def parse
    validate_header!

    Result.new(
      batch_attributes: batch_attributes_from(parse_metadata(metadata_lines)),
      batch_data_rows: parse_data_rows(data_lines)
    )
  end

  private

  attr_reader :content

  def lines
    @lines ||= content.each_line.map(&:chomp)
  end

  def data_section_index
    @data_section_index ||= lines.index { |line| line.strip == DATA_SECTION_MARKER }
  end

  def metadata_lines
    lines[1...data_section_index]
  end

  def data_lines
    lines[(data_section_index + 1)..]
  end

  def validate_header!
    unless lines.first&.strip == EXPECTED_HEADER
      raise InvalidFileError, "Arquivo não reconhecido (esperado cabeçalho \"#{EXPECTED_HEADER}\")"
    end

    raise InvalidFileError, "Seção #{DATA_SECTION_MARKER} não encontrada no arquivo" if data_section_index.nil?
  end

  def parse_metadata(section_lines)
    metadata = {}
    current_key = nil

    section_lines.each { |line| current_key = collect_metadata_line(metadata, current_key, line.strip) }

    metadata
  end

  def collect_metadata_line(metadata, current_key, stripped)
    if stripped =~ SECTION_KEY_REGEX
      key = Regexp.last_match(1)
      metadata[key] = nil
      return key
    end

    metadata[current_key] = stripped if current_key && stripped.present?
    current_key
  end

  def parse_data_rows(section_lines)
    CSV.parse(section_lines.join("\n"), headers: true).map { |row| data_row_attributes(row) }
  rescue CSV::MalformedCSVError => e
    raise InvalidFileError, "Falha ao ler os dados da torra: #{e.message}"
  end

  def data_row_attributes(row)
    {
      time_in_milliseconds: row["Time"].to_i,
      bean_temperature_in_celsius: row["BT"].to_i,
      exaust_temperature_in_celsius: row["ET"].to_i,
      ror: row["RoR"].to_d,
      power: row["HP"].to_d,
      air_flow: row["SM"].to_d,
      drum_rotation: row["RL"].to_d
    }
  end

  # rubocop:disable Metrics/MethodLength
  def batch_attributes_from(metadata)
    {
      batch_number: batch_number_from(metadata),
      total_time_in_seconds: RoastEventValueParser.duration(metadata["TotalTime"]),
      start_celsius_temperature: metadata["PreTemp"]&.to_i
    }.merge(
      event_attributes(
        :turning_point_celsius_temperature,
        :turning_point_time_in_seconds,
        metadata["TemperBack"]
      )
    )
      .merge(
        event_attributes(
          :turn_to_yellow_celsius_temperature,
          :turn_to_yellow_time_in_seconds,
          metadata["TurntoYellow"]
        )
      )
      .merge(
        event_attributes(
          :first_crack_celsius_temperature,
          :first_crack_time_in_seconds,
          metadata["1stBoomStart"]
        )
      )
  end
  # rubocop:enable Metrics/MethodLength

  def event_attributes(temperature_key, time_key, value)
    temperature, time = RoastEventValueParser.event(value)
    { temperature_key => temperature, time_key => time }
  end

  def batch_number_from(metadata)
    cook_date = RoastEventValueParser.cook_date(metadata["CookDate"])
    RoastEventValueParser.batch_number(cook_date)
  end
end
# rubocop:enable Metrics/ClassLength
