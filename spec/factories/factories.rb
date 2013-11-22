FactoryGirl.define do
  factory :event do
    initialize_with { new(attributes) }
    name "Bob's party"
    description "We will be celebrating Bob's birthday!"
    category 'parties'
    subcategory 'birthday party'
    start_time DateTime.parse('2013-05-05')
    end_time DateTime.parse('2013-05-07')
    city 'Sopot'
    address 'Bohaterów Monte Cassino 60, 81-759'
    country 'Poland'
    owner 'some_id'
    private true
  end
  
  factory :user do
    email 'user@example.com'
    password_digest 'newpassword'
  end
end