class RatingsController < ApplicationController
  def show
  end

  def new
  end

  def create
    @film=Film.find_by_id(params[:film_id])
    rating=Rating.new
    rating.film_id=params[:film_id]
    rating.user_id=params[:user_id]
    rating.value=params[:value]
    if rating.save
      flash[:success] = "Thank you!"
      redirect_to @film
    else
      flash[:error] = "Sorry, you probably already rated this film, or didn't choose value for rating"
      redirect_to @film
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:film_id, :user_id, :value)
  end
end
