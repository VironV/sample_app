class FilmsController < ApplicationController
  def show
    @film=Film.find(params[:id])
    if signed_in?
      @rating=Rating.new
      @user=current_user
    end
  end

  def new
  end

  def create
  end


end
