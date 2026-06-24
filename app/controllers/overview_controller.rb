class OverviewController < ApplicationController
  # The dashboard only reads the current household's own (already tenant-scoped)
  # data, so there's no per-record authorization to perform.
  skip_after_action :verify_authorized

  def show
    @date = selected_month_date
    @statement = MonthlyStatement.new(Current.household, @date.year, @date.month)
    @expenses = @statement.expenses
  end
end
