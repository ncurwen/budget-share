class SettlementsController < ApplicationController
  # Record (or re-record) the square-up for a month and mark it settled.
  def create
    year = params[:year].to_i
    month = params[:month].to_i
    statement = MonthlyStatement.new(Current.household, year, month)
    square_up = statement.square_up

    @settlement = Current.household.settlements.find_or_initialize_by(year:, month:)
    authorize @settlement

    if square_up.nil? || square_up.is_a?(Settlement)
      redirect_back fallback_location: month_path(year, month),
                    alert: "There's nothing to square up for this month."
      return
    end

    @settlement.assign_attributes(
      debtor: square_up.debtor,
      creditor: square_up.creditor,
      amount_cents: square_up.amount_cents
    )
    @settlement.settle!(Current.user)
    redirect_back fallback_location: month_path(year, month), notice: "Squared up. Nice work!"
  end

  # Undo a recorded square-up.
  def update
    @settlement = Current.household.settlements.find(params[:id])
    authorize @settlement
    @settlement.update!(settled_at: nil, settled_by: nil)
    redirect_back fallback_location: month_path(@settlement.year, @settlement.month),
                  notice: "Square-up reopened."
  end
end
