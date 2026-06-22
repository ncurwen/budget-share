module ApplicationHelper
  FLASH_ALERT_CLASSES = {
    "notice" => "alert-success",
    "success" => "alert-success",
    "alert" => "alert-error",
    "error" => "alert-error"
  }.freeze

  def flash_alert_class(type)
    FLASH_ALERT_CLASSES.fetch(type.to_s, "alert-info")
  end

  # Formats integer cents as currency, e.g. 1234 => "$12.34".
  def cents_to_currency(cents, **options)
    number_to_currency((cents || 0).fdiv(100), **options)
  end

  # DaisyUI badge for a category, colored by its chosen color.
  def category_badge(category, extra_classes: "")
    color = category.color.presence
    classes = [ "badge", "badge-sm", ("badge-#{color}" if color), extra_classes ].compact.join(" ")
    content_tag(:span, category.name, class: classes)
  end

  MONTH_NAMES = Date::MONTHNAMES.freeze

  def month_label(date)
    "#{MONTH_NAMES[date.month]} #{date.year}"
  end
end
