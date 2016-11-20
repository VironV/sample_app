class StaticPagesController < ApplicationController
  def home
    if signed_in?
      redirect_to current_user
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def films_list
    @films=Film.all()
  end
end
