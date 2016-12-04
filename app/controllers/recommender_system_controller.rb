class RecommenderSystemController < ApplicationController

  def show

  end

  def show_results
    f=File.open("logs.txt", "w")
    f.write("test")
    f.close()
    #first_full_learning()
    #init_params()

    @user_vectors=[]
    User.all.each do |user|
      user_id=user.id
      vector=[]
      User_factor.where(user_id: user_id).find_each do |factor|
        puts factor.value
        vector.push(factor.value)
      end
      @user_vectors.push(vector)
    end

    @film_vectors=[]
    Film.all.each do |film|
      film_id=film.id
      vector=[]
      Film_factor.where(film_id: film_id).find_each do |factor|
        vector.push(factor.value)
      end
      @user_vectors.push(vector)
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

  def init_params(learning_rate=0.1,f_regulator=0.015, f_amount=6, f_default=0.00001,max_iterations=150)
    change_param("learning_rate",learning_rate)
    change_param("f_regulator",f_regulator)
    change_param("f_amount",f_amount)
    change_param("f_default",f_default)
    change_param("max_iterations",max_iterations)
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
    if (param==nil)
      param =SVD_param.new
      param.name=name
      param.value=value
      param.save()
    else
      param.value=value
      param.save()
    end
    file.write("\nname " + name + "  value " + value.to_s)
    file.write("\nAFTER SAVE value " + param.value.to_s)
    file.close()
    #puts value
    #puts "db:" + param.value
  end

  def set_factors_amount(f_amount)
    amount_now=Factor.count;
    if amount_now==f_amount
      return
    elsif  amount_now>f_amount
      factors=Factor.all()
      count=0
      factors.each do |factor|
        if count>=f_amount
          factor.destroy
        end
        count+=1
      end
    else
      f_amount.to_i.times do |i|
        if (i>=amount_now)
          factor=Factor.new

          factor.name="factor " + i.to_s
          factor.save()
        end
      end
    end
  end

  def set_default_users_factors()
    User.all.each do |user|
      Factor.all.each do |factor|
        u_f=User_factor.new
        u_f.user_id=user.id
        u_f.factor_id=factor.id
        u_f.value=SVD_param.find_by_name("f_default").value
        u_f.save()
      end
    end
  end

  def set_default_films_factors()
    Film.all.each do |film|
      Factor.all.each do |factor|
        u_f=Film_factor.new
        u_f.film_id=film.id
        u_f.factor_id=factor.id
        u_f.value=SVD_param.find_by_name("f_default").value
        u_f.save()
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

  def predict_rating(user,film)
    file=File.open("logs.txt", "a")

    f_amount=SVD_param.find_by_name("f_amount").value.to_i

    gl_av_rating=get_global_av_rating()
    user_av_rating=get_user_av_rating(user.id,gl_av_rating)
    film_av_rating=get_film_av_rating(film.id,gl_av_rating)
    baseline=gl_av_rating + user_av_rating + film_av_rating

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
        (sum_vectors(user_f_vect,regulated_oth_films_sum_vect))
    )

    return prediction
  end

  def update_factors(user,film,error)
    file=File.open("logs.txt", "a")

    user_id=user.id
    film_id=film.id
    Factor.all.each do |proto_factor|
      f_id=proto_factor.id
      learn_rate=SVD_param.find_by_name("learning_rate").value
      f_regulator=SVD_param.find_by_name("f_regulator").value

      user_f=User_factor.find_by_user_id_and_factor_id(user_id,f_id)
      user_f_old=user_f.value
      film_f=Film_factor.find_by_film_id_and_factor_id(film_id,f_id)
      film_f_old=film_f.value
      user_f.value=user_f_old + learn_rate*(error*film_f_old - f_regulator*user_f_old)
      film_f.value=film_f_old + learn_rate*(error*user_f_old - f_regulator*film_f_old)

      file.write("\nlearn_rate " + learn_rate.to_s + " error " + error.to_s + " f_regulator " + f_regulator.to_s)
      file.write("\nOLD user " + user.id.to_s + " factor id " + f_id.to_s + " value " + user_f_old.to_s)
      file.write("\nOLD film " + film.id.to_s + " factor id " + f_id.to_s + " value " + film_f_old.to_s)
      file.write("\nuser " + user.id.to_s + " factor id " + f_id.to_s + " value " + user_f.value.to_s)
      file.write("\nfilm " + film.id.to_s + " factor id " + f_id.to_s + " value " + film_f.value.to_s)

      user_f.save()
      film_f.save()
    end
    file.close()
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

  def first_full_learning()
    file=File.open("logs.txt", "a")

    destoy_old_factors()
    init_params()

    l_r=SVD_param.find_by_name("learning_rate")
    file.write("\nlearning_rate=" + l_r.to_s)


    set_default_users_factors()
    set_default_films_factors()

    max_iter=SVD_param.find_by_name("max_iterations").value.to_i
    learning_rate=SVD_param.find_by_name("learning_rate")
    ratings_count=Rating.all.count

    rmse=1
    rmse_old=0
    threshold=0.01
    iter_count=0
    while (rmse-rmse_old).abs>0.00001
      iter_count+=1
      rmse_old=rmse
      rmse=0
      Rating.all.each do |rating|
        error=train_rating_and_get_error(rating)
        rmse+=error*error
      end

      rmse=rmse/ratings_count

      if rmse > (rmse_old-threshold)
        old_leatn_rate=learning_rate.value
        learning_rate.value=old_leatn_rate*0.66
        learning_rate.save()
        threshold=threshold*0.5
      end

      if iter_count>max_iter
        break
      end
    end
    file.close()
  end

  def added_rating(rating)
    max_iter=SVD_param.find_by_name("max_iterations").value
    learning_rate=SVD_param.find_by_name("learning_rate")
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
        learning_rate.save()
        threshold=threshold*0.5
      end

      if iter_count>max_iter
        break
      end
    end
  end

  def train_rating_and_get_error(rating)
    file=File.open("logs.txt", "a")

    user=User.find(rating.user_id)
    film=Film.find(rating.film_id)

    predicted=predict_rating(user=user,film=film)
    error=rating.value-predicted
    update_factors(user=user,film=film,error=error)

    file.write("\nPredicted " + predicted.to_s + " error=" + error.to_s + " for user " + user.id.to_s + " and film " + film.id.to_s)
    file.close()

    return error
  end

end

