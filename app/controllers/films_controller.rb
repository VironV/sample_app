class FilmsController < ApplicationController
  def show
    @film=Film.find(params[:id])
    if signed_in?
      @rating=Rating.new
      @user=current_user
      @preference=Preference.find_by_fan_id_and_favfilm_id(current_user.id,@film.id)
      if @preference==nil
        @preference=Preference.new
      end
    end
  end

  def new
  end

  def create
  end


end
