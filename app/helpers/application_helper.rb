module ApplicationHelper

  def format_duration(seconds)
    return unless seconds

    minutes = seconds /60
    seconds %= 60

    format("%d:%02d", minutes, seconds)
  end
end
