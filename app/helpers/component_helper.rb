module ComponentHelper
  def dialog_tag(**, &block) = render(DialogComponent.new(**), &block)
  def table_tag(**, &block) = render(TableComponent.new(**), &block)
  def timeago_tag(...) = render TimeagoComponent.new(...)
end
