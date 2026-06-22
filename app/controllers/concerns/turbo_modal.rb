# Shared behaviour for controllers whose new/edit forms load into the page's
# "modal" Turbo Frame.
module TurboModal
  extend ActiveSupport::Concern

  included do
    # Frame requests return just the dialog, so they skip the application layout.
    layout -> { "application" unless turbo_frame_request? }
  end

  private

  # Close the modal and morph the current page. `request_id: nil` stops Turbo from
  # deduping the refresh against the very form submission that triggered it.
  def morph_refresh
    render turbo_stream: turbo_stream.refresh(request_id: nil)
  end
end
