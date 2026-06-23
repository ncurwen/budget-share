class ApplicationComponent < ViewComponent::Base
  # Helpers our component templates call bare (not via the `helpers` proxy):
  # `lucide_icon` (added to ActionView by the lucide-rails railtie, but not to
  # ViewComponent::Base) and app helpers such as `tooltip_tag`.
  include LucideRails::RailsHelper
  include ApplicationHelper
end
