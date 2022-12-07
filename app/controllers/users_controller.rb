

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