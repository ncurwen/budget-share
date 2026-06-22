class ExpensesController < ApplicationController
  include TurboModal

  before_action :set_expense, only: %i[edit update destroy]

  def index
    @date = selected_month_date
    scope = policy_scope(Expense).for_month(@date.year, @date.month)
                                 .includes(:category, :user).recent_first
    scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
    @expenses = scope
    @categories = current_household.categories
  end

  def new
    @expense = current_household.expenses.new(paid_on: Date.current, shared: true)
    authorize @expense
  end

  def create
    @expense = current_household.expenses.new(expense_params)
    authorize @expense

    if @expense.save
      refresh_with "Expense added."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @expense
  end

  def update
    authorize @expense

    if @expense.update(expense_params)
      refresh_with "Expense updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @expense
    @expense.destroy
    refresh_with "Expense deleted."
  end

  private

  def set_expense
    @expense = current_household.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense)
          .permit(:title, :description, :paid_on, :amount, :shared, :category_id, :user_id)
  end

  def refresh_with(message)
    flash[:notice] = message
    respond_to do |format|
      format.turbo_stream { morph_refresh }
      format.html { redirect_back fallback_location: expenses_path }
    end
  end
end
