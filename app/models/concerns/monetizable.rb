# Adds decimal-dollar accessors on top of an integer `*_cents` column so forms
# and views can work in dollars while storage stays exact.
#
#   monetize :amount_cents   # => #amount / #amount=
module Monetizable
  extend ActiveSupport::Concern

  class_methods do
    def monetize(cents_attribute, as: cents_attribute.to_s.sub(/_cents$/, ""))
      define_method(as) do
        cents = public_send(cents_attribute)
        cents&.fdiv(100)
      end

      define_method("#{as}=") do |value|
        cents = value.blank? ? nil : (BigDecimal(value.to_s) * 100).round
        public_send("#{cents_attribute}=", cents)
      end
    end
  end
end
