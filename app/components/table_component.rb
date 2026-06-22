class TableComponent < ApplicationComponent
  ROW_CLASS = "hover:bg-base-300 even:bg-base-100 odd:bg-base-200"
  LINK_CLASS = "text-sm sm:text-base md:text-lg link link-primary link-hover"
  class ColumnComponent < ApplicationComponent
    attr_reader :css_class

    def initialize(css_class: nil)
      @css_class = css_class
    end

    def call = content
  end

  renders_many :columns, ColumnComponent
  renders_one :empty_message

  def initialize(collection:, partial:, as:,
                 search_config: nil,
                 filter_config: nil,
                 show_actions: false,
                 empty_message_button_config: nil,
                 **row_locals)
    @collection = collection
    @partial = partial
    @as = as
    @search_config = search_config
    @filter_configs = Array.wrap(filter_config).compact
    @show_actions = show_actions
    @empty_message_button_config = empty_message_button_config
    @row_locals = row_locals
  end

  def show_actions? = @show_actions
  def empty? = @collection.empty?
  def truly_empty?    = @collection.empty? && !searching? && !filter_active?
  def filtered_empty? = @collection.empty? && (searching? || filter_active?)
  def total_colspan = columns.count + (show_actions? ? 1 : 0)
  def filter_config? = @filter_configs.present?
  def searching? = @search_config&.dig(:value).present?
  def clearable? = searching? || filter_active? || sort_param.present?

  def filter_active?(value = nil)
    value ? @filter_configs.any? { |fc| fc[:active].to_s == value.to_s } : @filter_configs.any? { |fc| fc[:active].present? }
  end

  def sort_param
    s = helpers.params.dig(:q, :s)
    s = s.first if s.is_a?(Array)
    s.presence if s.is_a?(String)
  end

  def toggle_filter_url(config, value)
    q = { @search_config[:attribute] => @search_config[:value] }
    @filter_configs.each do |fc|
      q[fc[:param]] = fc.equal?(config) ? (fc[:active].to_s == value.to_s ? nil : value) : fc[:active]
    end
    q[:s] = sort_param
    q.compact_blank!
    q.empty? ? @search_config[:url] : "#{@search_config[:url]}?#{ { q: q }.to_query }"
  end

  private

  def render_rows
    helpers.render(partial: @partial, collection: @collection, as: @as,
                   locals: @row_locals.merge(show_actions: show_actions?, row_class: ROW_CLASS, link_class: LINK_CLASS))
  end
end
