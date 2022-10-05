Role.destroy_all
Role.create!([
  {
    id: 1,
    name: 'admin'
  },
  {
    id: 2,
    name: 'user'
  },
  {
    id: 3,
    name: 'ta'
  }
])

User.destroy_all
(1..10).each do |id|
  User.create!([
   {
     id: id,
     name: Faker::Name.name,
     email: Faker::Internet.email,
     role_id: rand(1..3)
   }
  ])
end

Referral.destroy_all
(1..10).each do |id|
  Referral.create!([
   {
     referred_by: rand(1..10),
     full_name: Faker::Name.name,
     phone_number: Faker::PhoneNumber.phone_number_with_country_code,
     email: Faker::Internet.email,
     linkedin_url: "https://linkedin.com/example.#{id}",
     cv_url: "https://mycv.com/example.#{id}",
     tech_stack: "ruby, RoR",
     ta_recruiter: rand(1..10),
     active: true,
     status: 1,
     signed_date: Faker::Date.between(from: Time.now-20, to: Time.now),
     comments: "Referral comments"
   }
 ])
end

ActiveRecord::Base.connection.reset_pk_sequence!('roles')
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('referrals')
