class FilmsController < ApplicationController
  def show
    @film=Film.find(params[:id])
  end

  def new
  end

  def create
  end


end
