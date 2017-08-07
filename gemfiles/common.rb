# common requirements for all setups

source 'https://rubygems.org'

gem 'grape'
gem 'grape-entity'
gem 'rack-cors'
gem 'rack-contrib'
gem 'multi_json'
gem 'oj'
gem 'puma'

gem 'scorched'
gem 'haml'

group :development do
  gem "guard"
  gem "guard-rack"
end

group :testing do
  gem 'minitest'
  gem 'rack-test'
  gem 'rake'
end
