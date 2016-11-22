class PreferencesController < ApplicationController
  def show
  end

  def new
  end

  def create
    @film=Film.find_by_id(params[:film_id])
    preference=Preference.new
    preference.fan_id=params[:user_id]
    preference.favfilm_id=params[:film_id]
    if preference.save
      flash[:success] = "Film added to you favourites"
      redirect_to @film
    else
      flash[:error] = "Sorry, something went wrong. Please, try again later"
      redirect_to @film
    end
  end

  def destroy
    @film=Film.find_by_id(params[:film_id])
    old_preference=Preference.find_by_fan_id_and_favfilm_id(params[:user_id],params[:film_id])
    if old_preference
      old_preference.destroy
      flash[:success] = "Film removed from your favourites"
      redirect_to @film
    else
      flash[:error] = "Error: this film is not in your favourites"
      redirect_to @film
    end
  end
end
