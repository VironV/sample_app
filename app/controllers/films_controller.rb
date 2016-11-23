class FilmsController < ApplicationController
  def show
    @film=Film.find(params[:id])
    if signed_in?
      @rating=Rating.find_by_film_id_and_user_id(@film.id,current_user.id)
      @user=current_user
      @preference=Preference.find_by_fan_id_and_favfilm_id(current_user.id,@film.id)

      ratings_list=Rating.where(film_id: @film.id)
      @av_rating=nil
      if ratings_list.count>0
        sum=0.0
        count=0
        ratings_list.each do |rate|
          sum+=rate.value
          count+=1
        end
        @av_rating=(sum/count).round(2)
      end

      if @preference==nil
        @preference=Preference.new
      end
      if @rating==nil
        @rating=Rating.new
      end
    end
  end

  def new
  end

  def create
  end


end
