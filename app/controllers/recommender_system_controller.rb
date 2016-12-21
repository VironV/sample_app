class RecommenderSystemController < ApplicationController

  @learning_rate_str
  @f_regulator_str
  @f_amoun_str
  @f_default_str
  @max_iterations_str
  @global_predictor_str

  def initialize
    @learning_rate_str="learning_rate"
    @f_regulator_str="f_regulator"
    @f_amoun_str="f_amount"
    @f_default_str="f_default"
    @max_iterations_str="max_iterations"
    @global_predictor_str="global_predictor"
  end

  def show_choice

  end

  def show_recommended_films
    user=current_user

    rated_films=User.rated_films(user.id)
    rated_films_id=[]
    rated_films.each do |rated_film|
      rated_films_id.push(rated_film.film_id)
    end

    unrated_films=Film.where.not(id: rated_films_id)
    unrated_films_id=[]
    unrated_films.each do |unrated_film|
      unrated_films_id.push(unrated_film.id)
    end

    #rated_films_id.each do |i|
    #  puts("Rated films: " + i.to_s)
    #end

    unrated_films_h={}
    Film.all.each do |film|
      if unrated_films_id.include?(film.id)
        rating=predict_rating(user,film)
        temp={film.title => rating}
        unrated_films_h.merge!(temp)
      end
    end
    @unrated_films=unrated_films_h.sort_by {|_key, value| value}


  end

  def show_results
    @users=[]
    @user_vectors=[]
    @user_predictor=[]
    User.all.each do |user|
      @users.push(user.name)
      @user_predictor.push(user.base_predictor)
      user_id=user.id
      vector=[]
      User_factor.where(user_id: user_id).find_each do |factor|
        #puts factor.value
        vector.push(factor.value)
      end
      @user_vectors.push(vector)
    end

    @films=[]
    @film_vectors=[]
    @film_predictor=[]
    Film.all.each do |film|
      @films.push(film.title)
      @film_predictor.push(film.base_predictor)
      film_id=film.id
      vector=[]
      Film_factor.where(film_id: film_id).find_each do |factor|
        vector.push(factor.value)
      end
      @film_vectors.push(vector)
    end

    @SVD_params=[]
    SVD_param.all.each do |param|
      @SVD_params.push(param)
    end
  end

  def calculate_and_show_results
    log_write_init

    first_full_learning
    #init_params()
    show_results
  end

  #
  #Main part
  #
  #This fucntion calculates predicted rating using existing factors' and predictors' values,
  #and returns that prediction
  def predict_rating(user,film)
    f_amount=SVD_param.find_by_name(@f_amoun_str).value.to_i

    mu=SVD_param.find_by_name(@global_predictor_str).value
    user_prd=user.base_predictor
    film_prd=film.base_predictor

    baseline=mu+user_prd+film_prd

    user_f_vect=create_user_factor_vector(user.id)
    film_f_vect=create_film_factor_vector(film.id)

    prediction=baseline + multiply_vectors(
        film_f_vect,
        user_f_vect
    )
    return prediction
  end

  #This function begins new learning cycle to get right factors and predcitors
  def first_full_learning()
    destoy_old_factors
    init_params

    global_av=get_global_av_rating
    set_default_users_factors(global_av)
    set_default_films_factors(global_av)

    #getting learning process params
    max_iter=SVD_param.find_by_name(@max_iterations_str).value.to_i
    learn_rate=SVD_param.find_by_name(@learning_rate_str).value
    ratings_count=Rating.all.count
    f_regulator=SVD_param.find_by_name(@f_regulator_str).value

    rmse=1
    rmse_old=0
    threshold=0.01
    iter_count=0
    while (rmse-rmse_old).abs>0.0001
      iter_count+=1
      rmse_old=rmse
      rmse=0

      log_write_iter_count(iter_count)

      Rating.all.each do |rating|
        user=User.find(rating.user_id)
        film=Film.find(rating.film_id)

        #get prediction and calculate error
        predicted=predict_rating(user=user,film=film)
        error=rating.value-predicted
        rmse+=error*error

        log_write_rating_and_error(rating,error,learn_rate,predicted)

        #update factors and predictors
        update_base_predictors(user,film,error,learn_rate,f_regulator)
        update_factors(user.id,film.id,learn_rate,error,f_regulator)
      end

      #calculate rmse
      rmse=rmse/ratings_count

      log_write_rmse(rmse,rmse_old)

      #if rmse changes by small amout - slow down learning rate
      if (rmse - rmse_old).abs < threshold
        learn_rate*=0.66
        threshold=threshold*0.5
      end
      #if iterations count is too big - stop learning
      if iter_count > max_iter
        break
      end
    end

    l_r=SVD_param.find_by_name(@learning_rate_str)
    l_r.value=learn_rate
    l_r.save

  end
  ###

  #
  #Learning shortcuts functions
  #
  #This function gets error of prediction, and uses it for update predictors
  def update_base_predictors(user,film,error,learn_rate,f_regulator)
    mu=SVD_param.find_by_name(@global_predictor_str)
    mu.value=mu.value + error*learn_rate
    user.base_predictor=user.base_predictor+(error*learn_rate - f_regulator*user.base_predictor)
    film.base_predictor=film.base_predictor+(error*learn_rate - f_regulator*film.base_predictor)
    mu.save
    user.save
    film.save
  end

  #This function gets error of prediction, and uses it for update predictors
  def update_factors(user_id,film_id,learn_rate,error,f_regulator)
    Factor.all.each do |proto_factor|
      f_id=proto_factor.id

      user_f=User_factor.find_by_user_id_and_factor_id(user_id,f_id)
      film_f=Film_factor.find_by_film_id_and_factor_id(film_id,f_id)

      user_f_old=user_f.value
      film_f_old=film_f.value

      user_f.value=user_f_old + learn_rate*(error*film_f_old - f_regulator*user_f_old)
      film_f.value=film_f_old + learn_rate*(error*user_f_old - f_regulator*film_f_old)

      user_f.save
      film_f.save

      log_write_factors_changes(user_id,film_id,f_id,user_f_old,film_f_old,user_f,film_f)
    end
  end
  ###

  #
  #Init part
  #
  #This function preparing learning process params
  def init_params(learning_rate=0.1,f_regulator=0.015, f_amount=2, f_default=0.1,max_iterations=100)
    change_param(@learning_rate_str,learning_rate)
    change_param(@f_regulator_str,f_regulator)
    change_param(@f_amoun_str,f_amount)
    change_param(@f_default_str,f_default)
    change_param(@max_iterations_str,max_iterations)
    change_param(@global_predictor_str,0.0)
    set_factors_amount(f_amount)
  end

  #function to save params in database
  def change_param(name,value)
    param=SVD_param.find_by_name(name)
    if param==nil
      param =SVD_param.new
      param.name=name
      param.value=value
      param.save
    else
      param.value=value
      param.save
    end
    log_write_param(name,value,param)
  end

  #function to set amount of factors
  def set_factors_amount(f_amount)
    amount_now=Factor.count
    if amount_now==f_amount
      return
    elsif  amount_now>f_amount
      factors=Factor.all
      count=0
      factors.each do |factor|
        if count>=f_amount
          factor.destroy
        end
        count+=1
      end
    else
      f_amount.to_i.times do |i|
        if i>=amount_now
          factor=Factor.new

          factor.name="factor " + i.to_s
          factor.save
        end
      end
    end
  end

  #clear all old factors
  def destoy_old_factors
    User_factor.all.each do |factor|
      factor.destroy
    end

    Film_factor.all.each do |factor|
      factor.destroy
    end

    Factor.all.each do |factor|
      factor.destroy
    end
  end

  #set all user factors to default value
  def set_default_users_factors(global_av)
    User.update_all(:base_predictor => 0)
    User.all.each do |user|
      Factor.all.each do |factor|
        u_f=User_factor.new
        u_f.user_id=user.id
        u_f.factor_id=factor.id
        u_f.value=SVD_param.find_by_name("f_default").value
        u_f.save
      end
    end
  end

  #set all film factors to default value
  def set_default_films_factors(global_av)
    Film.update_all(:base_predictor => 0)
    count = 0
    Film.all.each do |film|
      Factor.all.each do |factor|
        count+=1
        u_f=Film_factor.new
        u_f.film_id=film.id
        u_f.factor_id=factor.id
        u_f.value=SVD_param.find_by_name(@f_default_str).value*count/2
        u_f.save
      end
    end
  end
  ###

  #
  #Helpers
  #
  def get_global_av_rating
    sum=Float(0)
    count=0
    Rating.all.each do |rating|
      sum+=rating.value
      count+=1
    end
    result= Float(sum)/count
    return result
  end

  #returns array of film factors
  def create_film_factor_vector(film_id)
    arr=[]
    Film_factor.where(film_id: film_id).find_each do |factor|
      arr.push(factor.value)
    end
    return arr
  end

  #returns array of user factors
  def create_user_factor_vector(user_id)
    arr=[]
    User_factor.where(user_id: user_id).find_each do |factor|
      arr.push(factor.value)
    end
    return arr
  end

  def multiply_vectors(vector1,vector2)
    size=vector1.size
    if vector2.size!=size
      return nil
    end

    result=0
    size.times do |i|
      result+=vector1[i]*vector2[i]
    end
    return result
  end

  def sum_vectors(vector1,vector2)
    size=vector1.size
    if vector2.size!=size
      return nil
    end

    result=[]
    size.times do |i|
      result.push(vector1[i]+vector2[i])
    end
    return result
  end
  ###

  #
  #Logs functions
  #
  def log_write_init()
    f=File.open("logs.txt", "w")
    f.write("RECOMMENDER SYSTEM LOGS:\n\n")
    f.close
  end

  def log_write_param(name,value,param)
    file=File.open("logs.txt", "a")
    file.write("\nname " + name + "  value " + value.to_s)
    file.write("\nAFTER SAVE value " + param.value.to_s)
    file.close
  end

  def log_write_iter_count(iter_count)
    file=File.open("logs.txt", "a")
    file.write("\n\n-----iter count: " + iter_count.to_s)
    file.close
  end

  def log_write_rating_and_error(rating,error,learn_rate,predicted)
    file=File.open("logs.txt", "a")
    file.write("\n--RATING: " + rating.value.to_s + " from user " + rating.user_id.to_s + "to film " + rating.film_id.to_s)
    file.write("\n--Predicted " + predicted.to_s + " error=" + error.to_s + " for user " + rating.user_id.to_s + " and film " + rating.film_id.to_s)
    file.write("\n--learn_rate " + learn_rate.to_s)
    file.close
  end

  def log_write_factors_changes(user_id,film_id,f_id,user_f_old,film_f_old,user_f,film_f)
    file=File.open("logs.txt", "a")
    file.write("\nOLD user " + user_id.to_s + " factor id " + f_id.to_s + " value " + user_f_old.to_s)
    file.write("\nOLD film " + film_id.to_s + " factor id " + f_id.to_s + " value " + film_f_old.to_s)
    file.write("\nuser " + user_id.to_s + " factor id " + f_id.to_s + " value " + user_f.value.to_s)
    file.write("\nfilm " + film_id.to_s + " factor id " + f_id.to_s + " value " + film_f.value.to_s)
    file.close
  end

  def log_write_rmse(rmse,rmse_old)
    file=File.open("logs.txt", "a")
    file.write("\nRMSE OLD " + rmse_old.to_s)
    file.write("\nRMSE NEW: " + rmse.to_s)
    file.close
  end

  def clear_all_data
    Film_factor.all.each do |factor|
      factor.destroy
    end
    User_factor.all.each do |factor|
      factor.destroy
    end
    Films_tag.all.each do |tag|
      tag.destroy
    end
    Users_tag.all.each do |tag|
      tag.destroy
    end
    Preference.all.each do |pref|
      pref.destroy
    end
    Rating.all.each do |rating|
      rating.destroy
    end
    Film.all.each do |film|
      film.destroy
    end
    User.all.each do |user|
      user.destroy
    end

  end

  def create_5_5_example
    if signed_in?
      sign_out
    end
    clear_all_data
    a=User.create(name: "Mary",email:"mary@email.com",password:"foobar",password_confirmation:"foobar")
    b=User.create(name: "Mike",email:"mike@email.com",password:"foobar",password_confirmation:"foobar")
    c=User.create(name: "Marco",email:"marco@email.com",password:"foobar",password_confirmation:"foobar")
    d=User.create(name: "Anna",email:"anna@email.com",password:"foobar",password_confirmation:"foobar")
    e=User.create(name: "Jack",email:"jack@email.com",password:"foobar",password_confirmation:"foobar")

    a_f=Film.create(title:"Love in a nutshell",director:"Unknown",year:"2000")
    b_f=Film.create(title:"In love",director:"Unknown",year:"2000")
    c_f=Film.create(title:"Fun and stuff",director:"Unknown",year:"2000")
    d_f=Film.create(title:"Fun,fun,fun",director:"Unknown",year:"2000")
    e_f=Film.create(title:"Make me laugh",director:"Unknown",year:"2000")

    Rating.create(film_id: a_f.id,user_id: a.id, value: 8)
    Rating.create(film_id: b_f.id,user_id: a.id, value: 9)
    Rating.create(film_id: c_f.id,user_id: a.id, value: 6)
    Rating.create(film_id: e_f.id,user_id: a.id, value: 5)

    Rating.create(film_id: a_f.id,user_id: b.id, value: 5)
    Rating.create(film_id: c_f.id,user_id: b.id, value: 8)
    Rating.create(film_id: d_f.id,user_id: b.id, value: 7)
    Rating.create(film_id: e_f.id,user_id: b.id, value: 9)

    Rating.create(film_id: a_f.id,user_id: c.id, value: 6)
    Rating.create(film_id: b_f.id,user_id: c.id, value: 8)
    Rating.create(film_id: c_f.id,user_id: c.id, value: 7)
    Rating.create(film_id: d_f.id,user_id: c.id, value: 3)
    Rating.create(film_id: e_f.id,user_id: c.id, value: 8)

    Rating.create(film_id: b_f.id,user_id: d.id, value: 10)
    Rating.create(film_id: c_f.id,user_id: d.id, value: 9)
    Rating.create(film_id: d_f.id,user_id: d.id, value: 7)
    Rating.create(film_id: e_f.id,user_id: d.id, value: 8)

    Rating.create(film_id: a_f.id,user_id: e.id, value: 4)
    Rating.create(film_id: b_f.id,user_id: e.id, value: 3)
    Rating.create(film_id: c_f.id,user_id: e.id, value: 5)
    Rating.create(film_id: d_f.id,user_id: e.id, value: 2)

    redirect_to root_url
  end

end

