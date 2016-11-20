require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_films
  end
end

def make_users
  main_example=User.create!(name: "MainExampleUser", email: "mainexample@email.com",
                            password: "foobar", password_confirmation: "foobar")
  10.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@email.com"
    password="password"
    User.create!(name: name,email:email,password: password, password_confirmation: password)
  end
end

def make_films
  10.times do |n|
    title = Faker::Book.title
    director = Faker::Name.name
    year = 2000
    Film.create!(title:title,director: director,year:year)
  end
end