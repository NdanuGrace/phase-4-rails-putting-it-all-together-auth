class RecipesController < ApplicationController

    rescue_from ActiveRecord::RecordInvalid, with: :valid_user

    before_action :authorize


    def index
        recipes = Recipe.all
        render json: recipes, include: :user
    end
    def create
        user = User.find_by(id: session[:user_id])
        recipe = user.recipes.create!(recipe_params)
        render json: recipe, status: :created, include: :user
    end

    private 

    def recipe_params
        params.permit(:title, :instructions, :minutes_to_complete, :user_id)
    end

    def authorize
        return render json: {errors: ["Not authorized"]}, status: :unauthorized unless session.include? :user_id
    end

    def valid_user(valid)
        render json:{errors: valid.record.errors.full_messages}, status: :unprocessable_entity
    end
end
