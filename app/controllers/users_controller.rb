class UsersController < ApplicationController
  def show
    @user=User.find(params[:id])
    pref_list=Preference.where(fan_id: @user.id)
    @films_list=[]
    pref_list.each do |pref|
      @films_list << Film.find(pref.favfilm_id)
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      flash[:error] = "Error"
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    if @user.save
      redirect_to @user
    else
      flash[:error] = "Error"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
