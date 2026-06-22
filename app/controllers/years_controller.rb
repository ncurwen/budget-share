class YearsController < ApplicationController
  skip_after_action :verify_authorized

  def show
    @year = selected_year
    @statement = AnnualStatement.new(current_household, @year)
  end
end
