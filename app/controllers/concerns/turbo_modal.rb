module TurboModal
  extend ActiveSupport::Concern

  included do
    # Frame requests return just the dialog, so they skip the application layout.
    layout -> { "application" unless turbo_frame_request? }
  end

  private

  def refresh_with(message, fallback_location: root_path)
    flash[:notice] = message
    respond_to do |format|
      format.turbo_stream { morph_refresh }
      format.html { redirect_back fallback_location: fallback_location }
    end
  end

  # `request_id: nil` stops Turbo from deduping the refresh against the very form submission that triggered it.
  def morph_refresh
    render turbo_stream: turbo_stream.refresh(request_id: nil)
  end
end
