class CategoriesController < ApplicationController
  include TurboModal

  before_action :set_category, only: %i[edit update destroy]

  def index
    @year = selected_year
    @q = policy_scope(Category).ransack(params[:q])
    @q.sorts = "position asc" if @q.sorts.empty?
    @pagy, @categories = pagy(@q.result)
  end

  def new
    @category = Current.household.categories.new
    authorize @category
  end

  def create
    @category = Current.household.categories.new(category_params)
    authorize @category

    if @category.save
      refresh_with "Category created.", fallback_location: categories_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @category
    @year = selected_year
    @targets = @category.targets_for_year(@year)
  end

  def update
    authorize @category
    @year = selected_year

    if @category.update(category_params)
      refresh_with "Category saved.", fallback_location: root_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @category

    if @category.destroy
      refresh_with "Category deleted.", fallback_location: categories_path
    else
      redirect_to categories_path, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = Current.household.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(
      :name, :color, :position,
      budget_targets_attributes: [ :id, :year, :month, :amount ]
    )
  end
end
