class ExpensesController < ApplicationController
  include TurboModal

  before_action :set_expense, only: %i[edit update destroy]

  def index
    @date = selected_month_date
    base = policy_scope(Expense).for_month(@date.year, @date.month)
                                .includes(:category, :user)
    @q = base.ransack(params[:q])
    @q.sorts = "paid_on desc" if @q.sorts.empty?
    result = @q.result
    @total_cents = result.sum(:amount_cents)
    @pagy, @expenses = pagy(result)
    @categories = Current.household.categories
  end

  def new
    @expense = Current.household.expenses.new(paid_on: Date.current, shared: true)
    authorize @expense
  end

  def create
    @expense = Current.household.expenses.new(expense_params)
    authorize @expense

    if @expense.save
      refresh_with "Expense added.", fallback_location: expenses_path
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
      refresh_with "Expense updated.", fallback_location: expenses_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @expense
    @expense.destroy
    refresh_with "Expense deleted.", fallback_location: expenses_path
  end

  private

  def set_expense
    @expense = Current.household.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense)
          .permit(:title, :description, :paid_on, :amount, :shared, :category_id, :user_id)
  end
end
