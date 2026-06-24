class YearsController < ApplicationController
  skip_after_action :verify_authorized

  def show
    @year = selected_year
    @statement = AnnualStatement.new(Current.household, @year)
  end
end
