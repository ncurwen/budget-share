require "test_helper"

class TimeagoComponentTest < ViewComponent::TestCase
  test "renders time element with iso8601 datetime value" do
    time = 2.hours.ago
    render_inline(TimeagoComponent.new(time))
    assert page.has_css?("time[data-timeago-datetime-value='#{time.iso8601}']")
  end

  test "sets content to I18n formatted time" do
    time = Time.zone.parse("2025-01-15 10:30:00")
    component = TimeagoComponent.new(time)
    assert_equal I18n.l(time, format: :long), component.content
  end

  test "parses string time" do
    component = TimeagoComponent.new("2025-06-01 12:00:00")
    assert_kind_of Time, component.time
  end

  test "renders nothing when time is blank" do
    render_inline(TimeagoComponent.new(nil))
    assert_equal "", rendered_content.strip
  end

  test "renders nothing when time is empty string" do
    render_inline(TimeagoComponent.new(""))
    assert_equal "", rendered_content.strip
  end

  test "suffix attribute defaults to true" do
    component = TimeagoComponent.new(1.hour.ago)
    assert component.suffix
  end

  test "suffix attribute can be set to false" do
    component = TimeagoComponent.new(1.hour.ago, suffix: false)
    assert_not component.suffix
  end

  test "passes suffix value to time element" do
    render_inline(TimeagoComponent.new(1.hour.ago, suffix: false))
    assert page.has_css?("time[data-timeago-add-suffix-value='false']")
  end

  test "sets refresh interval from constant" do
    render_inline(TimeagoComponent.new(1.hour.ago))
    assert page.has_css?("time[data-timeago-refresh-interval-value='#{TimeagoComponent::REFRESH_INTERVAL_MS}']")
  end

  test "direction defaults to top" do
    component = TimeagoComponent.new(1.hour.ago)
    assert_equal :top, component.direction
  end

  test "format defaults to :long" do
    component = TimeagoComponent.new(1.hour.ago)
    assert_equal :long, component.format
  end

  test "custom format is applied" do
    time = Time.zone.parse("2025-01-15 10:30:00")
    component = TimeagoComponent.new(time, format: :short)
    assert_equal I18n.l(time, format: :short), component.content
  end
end
