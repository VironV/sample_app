FactoryGirl.define do

  factory :user do |u|
    u.sequence(:name) {|n| "Name#{n}"}
    u.sequence(:email) {|n| "name#{n}@email.com"}
    u.password "foobar"
    u.password_confirmation "foobar"
  end

  factory :film do |f|
    f.sequence(:title) {|n| "Today or Tomorrow part#{n}"}
    f.director  "Adam Smith"
    f.year "1995"
  end

  factory :tag do
    title "Comedy"
    description "It's funny"
  end

  factory :factor do
    name "factor 1"
  end
end