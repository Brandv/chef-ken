class RecipesController < ApplicationController
  include ApplicationHelper
  include SessionsHelper
  include RecipesHelper

  def new
    @recipe = Recipe.new
    get_category
  end

  def create
    @recipe = get_category.recipes.new(recipe_params)
    current_user.recipes << @recipe
    if request.xhr?
      if @recipe.save
        flash.notice = "Your recipe has been added!"
        render partial: 'measures/new', recipe: @recipe
      else
        render :new
      end
    else
      if @recipe.save
        flash.notice = "Your recipe has been added!"

        redirect_to "/categories/#{@category.name}", notice: "You recipe was successfully added!"
      else
        render :new
      end
    end
  end

  def show
    if get_recipe
      if !!admin?
        redirect_to recipe_sales_path(@recipe)
      elsif logged_in
        @rating = Rating.new
        render :show
      else
        render 'general_use_partials/_login_required'
      end
    else
      render file: 'public/404.html'
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
    if recipe_owner?(@recipe) || admin?
      @category = Category.find(@recipe.category_id)
      if current_user.id != @recipe.user_id
        flash[:no_access] = "You do not have permission to edit this recipe."
        redirect_to @recipe
      end
    else
      render file: 'public/404.html'
    end
  end

  def destroy
    get_recipe
    if recipe_owner?(@recipe) || admin?
      @category = @recipe.category
      Recipe.destroy(@recipe)
      flash[:notice] = "The recipe has been deleted."
      redirect_to "/categories/#{@category.name}"
    else
      render file: 'public/404.html'
    end
  end


  def update
    @recipe = Recipe.find(params[:id])

    if @recipe.update(recipe_params)
      redirect_to @recipe
    else
      render 'edit'
    end
  end


  private

  def recipe_params
    params.require(:recipe).permit(:title, :category_id, :user_id, :directions, :time, :difficulty)
  end

   def get_category
    @category ||= Category.find_by(id: params[:category_id])
  end
end
