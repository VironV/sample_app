require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    #make_users
    make_films
    #make_ratings
    #make_preferenecs
  end
end

def make_users
  main_example=User.create!(name: "MainExampleUser", email: "mainexample@email.com",
                            password: "foobar", password_confirmation: "foobar")
  50.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@email.com"
    password="password"
    User.create!(name: name,email:email,password: password, password_confirmation: password)
  end
end

def make_films
  5.times do |n|
    title = Faker::Book.title
    director = Faker::Name.name
    year = 2000
    Film.create!(title:title,director: director,year:year)
  end
end

def make_ratings
  User.all.each do |u|
    num=Faker::Number.between(5,40)
    num.times do
      num1=Faker::Number.between(1,50)
      num2=Faker::Number.between(1,10)
      begin
        Rating.create!(user_id: u.id,film_id: num1, value: num2)
      rescue
        #nothing
      ensure
        #nothing
      end
    end
  end
end

def make_preferenecs
  User.all.each do |u|
    num=Faker::Number.between(1,12)
    num.times do
      num1=Faker::Number.between(1,50)
      begin
        Preference.create!(fan_id: u.id, favfilm_id: num1)
      rescue
        #nothing
      ensure
        #nothing
      end
    end
  end
end