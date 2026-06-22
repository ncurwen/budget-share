class CategoriesController < ApplicationController
  include TurboModal

  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = policy_scope(Category)
    @year = selected_year
  end

  def new
    @category = current_household.categories.new
    authorize @category
  end

  def create
    @category = current_household.categories.new(category_params)
    authorize @category

    if @category.save
      flash[:notice] = "Category created."
      respond_to do |format|
        format.turbo_stream { morph_refresh }
        format.html { redirect_to categories_path }
      end
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
      redirect_to categories_path(year: @year), notice: "Category saved."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @category

    if @category.destroy
      redirect_to categories_path, notice: "Category deleted."
    else
      redirect_to categories_path, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = current_household.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(
      :name, :color, :position,
      budget_targets_attributes: [ :id, :year, :month, :amount ]
    )
  end
end
