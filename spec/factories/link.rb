FactoryGirl.define do
  factory :link do
    short_url 'MgPA3'
    long_url 'http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html'
    clicks_count 0

    factory :invalid_link do
      short_url ''
      long_url ''
    end

    factory :short_link do
      short_url ''
    end
  end
end
