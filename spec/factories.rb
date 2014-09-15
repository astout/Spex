FactoryGirl.define do

  factory :user do
    first    "foo"
    last     "bar"
    login    "foobar"
    email    "foo@bar.com"
    role_id  Roles.find_by (default: true)
    password "coffee"
    password_confirmation "coffee"
  end

  factory :admin_user do
    first    "admin"
    last     "user"
    email    "astout@goalzero.com"
    login    "admin"
    password "coffee"
    password_confirmation "coffee"

    factory :admin do
      role_id  Roles.find_by(admin: true)
    end
  end

  factory :child1 do
    name    "child1"
  end

  factory :child2 do
    name    "child2"
  end

  factory :parent1 do
    name    "parent1"
  end

  factory :parent2 do
    name    "parent2"
  end

  factory :grand do
    name    "grand"
  end

  factory :great do
    name    "great"
  end

  factory :entity1 do
    name    "entity1"
  end

  factory :entity2 do
    name    "entity2"
  end
end