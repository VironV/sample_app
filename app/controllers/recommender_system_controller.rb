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

  def show

  end

  def get_random_unrated_films(user)
    #rnd_unrate_films = User.
  end

  def show_results
    f=File.open("logs.txt", "w")
    f.write("test")
    f.close
    first_full_learning
    #init_params()

    @users=[]

    @user_vectors=[]
    User.all.each do |user|
      @users.push(user.name)
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
    Film.all.each do |film|
      @films.push(film.title)
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

  #def show_results
  #  first_full_learning()
  #  @result="string"
  #end

  def init_params(learning_rate=0.1,f_regulator=0.000, f_amount=2, f_default=0.1,max_iterations=40)
    change_param(@learning_rate_str,learning_rate)
    change_param(@f_regulator_str,f_regulator)
    change_param(@f_amoun_str,f_amount)
    change_param(@f_default_str,f_default)
    change_param(@max_iterations_str,max_iterations)
    change_param(@global_predictor_str,0.0)
    #change_param("mu",get_global_av_rating)
    #change_param("user")
    set_factors_amount(f_amount)
  end

  def get_global_av_rating()
    sum=Float(0)
    count=0
    Rating.all.each do |rating|
      sum+=rating.value
      count+=1
    end
    result= Float(sum)/count
    return result
  end

  def get_user_av_rating(user_id,global_rating)
    sum=Float(0)
    count=0
    Rating.where(user_id: user_id).find_each do |rating|
      sum+=global_rating-rating.value
      count+=1
    end
    result= Float(sum)/count
    return result
  end

  def get_film_av_rating(film_id,global_rating)
    sum=Float(0)
    count=0
    Rating.where(film_id: film_id).find_each do |rating|
      sum+=global_rating-rating.value
      count+=1
    end
    result= Float(sum)/count
    return result
  end

  def change_param(name,value)
    file=File.open("logs.txt", "a")
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
    file.write("\nname " + name + "  value " + value.to_s)
    file.write("\nAFTER SAVE value " + param.value.to_s)
    file.close
    #puts value
    #puts "db:" + param.value
  end

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

  def set_default_films_factors(global_av)
    Film.update_all(:base_predictor => 0)
    count = 0
    Film.all.each do |film|
      #file=File.open("logs.txt", "a")
      #file.write("\n film " + film.title + " predictor: " + film.base_predictor.to_s)
      #file.close()
      #film.base_predictor=global_av-Film.average_rating(film.id)
      #film.save()
      #file=File.open("logs.txt", "a")
      #file.write("\n film " + film.title + " predictor: " + film.base_predictor.to_s)
      #file.close()
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

  def create_film_factor_vector(film_id)
    arr=[]
    Film_factor.where(film_id: film_id).find_each do |factor|
      arr.push(factor.value)
    end
    return arr
  end

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

  def destoy_old_factors()
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


  def predict_rating(user,film)
    f_amount=SVD_param.find_by_name(@f_amoun_str).value.to_i

    #gl_av_rating=get_global_av_rating
    #user_av_rating=get_user_av_rating(user.id,gl_av_rating)
    #film_av_rating=get_film_av_rating(film.id,gl_av_rating)
    #baseline=gl_av_rating + user_av_rating + film_av_rating
    mu=SVD_param.find_by_name(@global_predictor_str).value
    user_prd=user.base_predictor
    film_prd=film.base_predictor
    file=File.open("logs.txt", "a")
    file.write("\n film " + film.title + " predictor: " + film.base_predictor.to_s)
    file.write("\n name " + user.name + " predictor: " + user.base_predictor.to_s)
    file.write("\n mu= " + mu.to_s)
    file.close

    baseline=mu+user_prd+film_prd

    rated_films_count=0
    other_rated_films_vectors=[]
    Rating.where(user_id: user.id).find_each do |rating|
      if rating.film_id!=film.id
        rated_films_count+=1
        other_rated_films_vectors.push(create_film_factor_vector(rating.film_id))
      end
    end
    #rated_films_count=Rating.find_by_user_id(user.id).count

    films_regulator=1
    if (rated_films_count>0)
      films_regulator=rated_films_count ** -0.5
    end

    regulated_oth_films_sum_vect=[]

    f_amount.times do
      regulated_oth_films_sum_vect.push(0)
    end

    other_rated_films_vectors.each do |vector|
      f_amount.times do |i|
        #puts ("\n\n\n" + i.to_s + "\n\n\n")
        regulated_oth_films_sum_vect[i]+=vector[i]
      end
    end

    f_amount.times do |i|
      regulated_oth_films_sum_vect[i]*=films_regulator
    end

    user_f_vect=create_user_factor_vector(user.id)
    film_f_vect=create_film_factor_vector(film.id)

    prediction=baseline + multiply_vectors(
        film_f_vect,
        #(sum_vectors(user_f_vect,regulated_oth_films_sum_vect))
        user_f_vect
    )
    return prediction
  end

  def first_full_learning()


    destoy_old_factors
    init_params

    #file.write("\nlearning_rate=" + l_r.to_s)

    global_av=get_global_av_rating
    set_default_users_factors(global_av)
    set_default_films_factors(global_av)

    max_iter=SVD_param.find_by_name(@max_iterations_str).value.to_i
    learn_rate=SVD_param.find_by_name(@learning_rate_str).value
    ratings_count=Rating.all.count


    rmse=1
    rmse_old=0
    threshold=0.01
    iter_count=0
    while (rmse-rmse_old).abs>0.00001
      iter_count+=1

      file=File.open("logs.txt", "a")
      file.write("\n\n-----iter count: " + iter_count.to_s)
      file.close


      rmse_old=rmse
      rmse=0
      Rating.all.each do |rating|
        user=User.find(rating.user_id)
        film=Film.find(rating.film_id)
        user_id=rating.user_id
        film_id=rating.film_id


        file=File.open("logs.txt", "a")
        file.write("\nRATING: " + rating.value.to_s + " from user " + rating.user_id.to_s + "to film " + rating.film_id.to_s)
        file.close

        predicted=predict_rating(user=user,film=film)
        error=rating.value-predicted
        rmse+=error*error

        f_regulator=SVD_param.find_by_name(@f_regulator_str).value

        #update base predictors
        mu=SVD_param.find_by_name(@global_predictor_str)
        mu.value=mu.value + error*learn_rate
        user.base_predictor=user.base_predictor+(error*learn_rate - f_regulator*user.base_predictor)
        film.base_predictor=film.base_predictor+(error*learn_rate - f_regulator*film.base_predictor)

        mu.save
        user.save
        film.save

        #update user and film factors
        Factor.all.each do |proto_factor|
          f_id=proto_factor.id

          user_f=User_factor.find_by_user_id_and_factor_id(user_id,f_id)
          user_f_old=user_f.value
          film_f=Film_factor.find_by_film_id_and_factor_id(film_id,f_id)
          film_f_old=film_f.value
          user_f.value=user_f_old + learn_rate*(error*film_f_old - f_regulator*user_f_old)
          film_f.value=film_f_old + learn_rate*(error*user_f_old - f_regulator*film_f_old)

          #user_f.value=user_f.value + learn_rate*(error*film_f.value - f_regulator*user_f.value)
          #film_f.value=film_f.value + learn_rate*(error*user_f.value- f_regulator*film_f.value)

          user_f.save
          film_f.save


          file=File.open("logs.txt", "a")
          file.write("\nPredicted " + predicted.to_s + " error=" + error.to_s + " for user " + user.id.to_s + " and film " + film.id.to_s)

          file.write("\nlearn_rate " + learn_rate.to_s + " error " + error.to_s + " f_regulator " + f_regulator.to_s)
          file.write("\nOLD user " + user.id.to_s + " factor id " + f_id.to_s + " value " + user_f_old.to_s)
          file.write("\nOLD film " + film.id.to_s + " factor id " + f_id.to_s + " value " + film_f_old.to_s)
          file.write("\nuser " + user.id.to_s + " factor id " + f_id.to_s + " value " + user_f.value.to_s)
          file.write("\nfilm " + film.id.to_s + " factor id " + f_id.to_s + " value " + film_f.value.to_s)

          file.close

        end
      end

      rmse=rmse/ratings_count

      if (rmse - rmse_old).abs < threshold
        learn_rate*=0.66
        threshold=threshold*0.5
      end

      if iter_count>max_iter
        break
      end
    end

    l_r=SVD_param.find_by_name(@learning_rate_str)
    l_r.value=learn_rate
    l_r.save()

  end

  def train_rating_and_get_error(rating)


    user=User.find(rating.user_id)
    film=Film.find(rating.film_id)

    user_id=rating.user_id
    film_id=rating.film_id

    Factor.all.each do |proto_factor|
      predicted=predict_rating(user=user,film=film)
      error=rating.value-predicted

      f_id=proto_factor.id
      learn_rate=SVD_param.find_by_name(@learning_rate_str).value
      f_regulator=SVD_param.find_by_name(@f_regulator_str).value

      user_f=User_factor.find_by_user_id_and_factor_id(user_id,f_id)
      user_f_old=user_f.value
      film_f=Film_factor.find_by_film_id_and_factor_id(film_id,f_id)
      film_f_old=film_f.value
      #user_f.value=user_f_old + learn_rate*(error*film_f_old - f_regulator*user_f_old)
      #film_f.value=film_f_old + learn_rate*(error*user_f_old - f_regulator*film_f_old)

      user_f.value=user_f.value + learn_rate*(error*film_f.value - f_regulator*user_f.value)
      film_f.value=film_f.value + learn_rate*(error*user_f.value- f_regulator*film_f.value)

      user_f.save
      film_f.save


      file=File.open("logs.txt", "a")
      file.write("\nPredicted " + predicted.to_s + " error=" + error.to_s + " for user " + user.id.to_s + " and film " + film.id.to_s)

      file.write("\nlearn_rate " + learn_rate.to_s + " error " + error.to_s + " f_regulator " + f_regulator.to_s)
      file.write("\nOLD user " + user.id.to_s + " factor id " + f_id.to_s + " value " + user_f_old.to_s)
      file.write("\nOLD film " + film.id.to_s + " factor id " + f_id.to_s + " value " + film_f_old.to_s)
      file.write("\nuser " + user.id.to_s + " factor id " + f_id.to_s + " value " + user_f.value.to_s)
      file.write("\nfilm " + film.id.to_s + " factor id " + f_id.to_s + " value " + film_f.value.to_s)

      file.close
    end



    return 1
  end

  def added_rating(rating)
    max_iter=SVD_param.find_by_name(@max_iterations_str).value
    learning_rate=SVD_param.find_by_name(@learning_rate_str)
    rmse=1
    rmse_old=0
    threshold=0.01
    iter_count=0
    while (rmse-rmse_old).abs>0.00001
      iter_count+=1
      rmse_old=rmse
      rmse=0

      error=train_rating_and_get_error(rating)

      rmse+=error*error

      if rmse > (rmse_old-threshold)
        old_leatn_rate=learning_rate.value
        learning_rate.value=old_leatn_rate*0.66
        learning_rate.save
        threshold=threshold*0.5
      end

      if iter_count>max_iter
        break
      end
    end
  end

end

