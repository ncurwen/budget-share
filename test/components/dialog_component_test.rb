require "test_helper"

class DialogComponentTest < ViewComponent::TestCase
  test "renders the dialog wrapped in its Stimulus controller" do
    render_inline(DialogComponent.new) do |dialog|
      dialog.with_title { "Add expense" }
      dialog.with_body { "<p>form goes here</p>".html_safe }
    end

    assert_selector "div[data-controller='dialog-component'] dialog.modal[data-dialog-component-target='dialog']"
    assert_selector "h3", text: "Add expense"
    assert_selector "p", text: "form goes here"
  end

  test "does not emit its own Turbo frame" do
    # Turbo-loaded dialogs render into the shared `turbo_frame_tag "modal"`; the
    # component must never wrap itself in a frame.
    render_inline(DialogComponent.new(open: true)) do |dialog|
      dialog.with_body { "body".html_safe }
    end

    assert_no_selector "turbo-frame"
    assert_selector "dialog[data-dialog-auto-open='true']"
  end
end
