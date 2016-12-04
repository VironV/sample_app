require_relative 'SVD++.rb'

module Clustering
  def self.make_clustering (users_arr, products_arr, ratings_arr)
    users_count=users_arr.count
    products_count=products_arr.count

    users_hash={}
    users_count.times do |i|

      users_hash[users_arr[i]]=i
    end

    products_hash={}
    products_count.times do |i|
      products_hash[products_arr[i]]=i
    end
    #p users_hash
    #p products_hash

    #Create empty array for ratings
    vectors=[]
    users_count.times do
      vector=[]
      products_count.times do
        vector.push(nil)
      end
      vectors.push(vector)
    end
    #p vectors
    #puts

    #fill matrix
    ratings_arr.each do |rating|
      #p rating
      vectors[ users_hash[rating[0]] ][ products_hash[rating[1]] ]=rating[2]
    end
    #p vectors


  end

end

Clustering.make_clustering([0,1,2,3,4],[0,1,2,3,4],
                           [
                               [0,1,7],
                               [0,3,5],
                               [0,4,7],
                               [1,0,8],
                               [1,1,5],
                               [1,2,4],
                               [1,4,5],
                               [2,0,6],
                               [2,2,10],
                               [2,3,8],
                               [3,0,7],
                               [3,2,6],
                               [3,4,8],
                               [4,1,3],
                               [4,3,7],
                               [4,4,4]
                           ])

#users_id=User.pluck(:id)
#films_id=Film.pluck(:id)
#ratings=[]

#Rating.all.each do |rating|
#  ratings.push(*[rating.user_id,rating.film_id,rating,value])
#end

SVD.show_var()