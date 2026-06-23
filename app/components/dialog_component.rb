class DialogComponent < ApplicationComponent
  renders_one :title
  renders_one :body
  renders_one :footer

  def initialize(description: nil, close_on_backdrop: false, open: false,
                 id: SecureRandom.hex(4), css_class: nil)
    @close_on_backdrop = close_on_backdrop
    @css_class = css_class
    @description = description
    @id = id
    @open = open
  end
end
