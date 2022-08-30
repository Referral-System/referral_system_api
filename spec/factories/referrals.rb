FactoryBot.define do
  factory :referral do
    referred_by {}
    full_name { Faker::Name.name_with_middle }
    phone_number { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    cv_url { Faker::Internet.url }
    tech_stack {}
    ta_recruiter {}
    status { 1 }
    comments { Faker::String.random}
    signed_date { Time.current }
    active { true }

    sequence(:linkedin_url) { |n| "https://linkedin.com/example.#{n}"}
  end
end