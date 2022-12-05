
Filter changed files
2  
Gemfile
@@ -40,4 +40,4 @@ group :test do
gem 'shoulda-matchers', '~> 4.0'
end

gem "active_model_serializers", "~> 0.10.12"
gem "active_model_serializers"
4  
Gemfile.lock
@@ -180,7 +180,7 @@ PLATFORMS
x86_64-linux

DEPENDENCIES
active_model_serializers (~> 0.10.12)
active_model_serializers
bcrypt (~> 3.1.7)
byebug
foreman (~> 0.87)
@@ -194,4 +194,4 @@ DEPENDENCIES
tzinfo-data

BUNDLED WITH
 2.2.16
 2.3.24
31  
app/controllers/recipes_controller.rb
@@ -0,0 +1,31 @@
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
18  
app/controllers/sessions_controller.rb
@@ -0,0 +1,18 @@
class SessionsController < ApplicationController

def create
  user = User.find_by(username: params[:username])
  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    render json: user, status: :created
  else
    render json: {errors: ["Not authorized"]}, status: :unauthorized
  end
end

def destroy
  return render json: {errors:["Not authorized"]}, status: :unauthorized unless session.include? :user_id
  session.delete :user_id
  head :no_content 
end
end
30  
app/controllers/users_controller.rb
@@ -0,0 +1,30 @@
class UsersController < ApplicationController
rescue_from ActiveRecord::RecordInvalid, with: :valid_user

  def create
      user = User.create!(user_params)
      session[:user_id] = user.id
      render json: user, status: :created
  end

  def show
      user = User.find_by(id: session[:user_id])

      if user
      render json: user
      else
          render json: {error: "Not Authorized"}, status: :unauthorized
      end
  end

  private 

  def user_params
      params.permit(:username, :password, :password_confirmation, :image_url, :bio)
  end
  def valid_user(valid)
      render json:{errors: valid.record.errors.full_messages}, status: :unprocessable_entity
  end

end