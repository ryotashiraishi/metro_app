source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.5'

# Use sqlite3 as the database for Active Record
group :development do
  gem 'sqlite3'
end

# Use SCSS for stylesheets
gem 'sass-rails', :git => 'https://github.com/zakelfassi/sass-rails' # Until the gem is officially updated.

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# for Production 
group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'unicorn'
end

# Facebook認証
gem 'omniauth-facebook', '1.4.0'

# デバッグ用
group :development do
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-nav'
end

# Bootflatの導入
gem 'bootflat-rails', '~> 0.1.9'

# Httpクライアント
gem 'faraday'
