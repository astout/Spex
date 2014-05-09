FactoryGirl.define do
  factory :user do
    name     "Alex Stout"
    email    "astout@goalzero.com"
    login    "astout"
    role     1
    password "coffee"
    password_confirmation "coffee"
  end
end