require 'factory_bot'

FactoryBot.define do
  factory :playlist do
    name { :my_playlist }
    association :radio
  end
end
