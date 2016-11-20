FactoryGirl.define do
  factory :user do
    name     "Michael Hartl"
    email    "michael@example.com"
    password "foobar"
    password_confirmation "foobar"
  end

  factory :film do
    title "Today or Tomorrow"
    director  "Adam Smith"
    year "1995"
  end

  factory :tag do
    title "Comedy"
    description "It's funny"
  end
end