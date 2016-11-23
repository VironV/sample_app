class RatingsController < ApplicationController
  def show
  end

  def new
  end

  def create
    @film=Film.find_by_id(params[:film_id])

    if params[:rating][:value] == '0'
      flash[:error] = "Error: you didn't choose value for rating"
      redirect_to @film
      return
    end

    rating=Rating.new
    rating.film_id=params[:film_id]
    rating.user_id=params[:user_id]
    rating.value=params[:rating][:value]
    if rating.save
      flash[:success] = "Your rating saved"
      redirect_to @film
    else
      flash[:error] = "Sorry, something went wrong. Please, try to again later"
      redirect_to @film
    end
  end

  def update
    @film=Film.find_by_id(params[:film_id])

    if params[:rating][:value] == '0'
      flash[:error] = "Error: you didn't choose value for rating"
      redirect_to @film
      return
    end

    rating=Rating.find_by_film_id_and_user_id(params[:film_id],params[:user_id])
    rating.value=params[:rating][:value]
    if rating.save
      flash[:success] = "Your rating changed"
      redirect_to @film
    else
      flash[:error] = "Sorry, something went wrong. Please, try to again later"
      redirect_to @film
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:film_id, :user_id, :value)
  end
end
