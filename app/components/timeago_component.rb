class TimeagoComponent < ApplicationComponent
  REFRESH_INTERVAL_MS = 10_000

  attr_reader :time, :content, :format, :suffix, :direction

  def initialize(time, format: :long, suffix: true, direction: :top)
    @time = time.present? ? (time.is_a?(String) ? Time.parse(time) : time) : nil
    return unless @time

    @content = I18n.l(@time, format: format)
    @format = format
    @suffix = suffix
    @direction = direction
  end

  def render?
    @time.present?
  end
end
