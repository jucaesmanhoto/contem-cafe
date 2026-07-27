module ApplicationHelper
  def format_duration(seconds)
    return unless seconds

    minutes = seconds / 60
    seconds %= 60

    format('%<minutes>d:%<seconds>02d', minutes: minutes, seconds: seconds)
  end
end
