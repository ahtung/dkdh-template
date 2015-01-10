# template.rb

# Clean up
remove_file 'app/views/layouts/application.html.erb'
remove_file 'README.rdoc'
remove_file 'config/database.yml'

## README
file 'README.md', <<-README
# #{@app_name}

# Tech

- Rails #{Rails::VERSION::STRING} 
- Foreman TODO
- Foundation TODO
- Postgresql

## Development

  foreman start -f Procfile.dev -e Procfile.dev.env

## Test

  foreman run rspec -e Procfile.test.env

## Production

  foreman start -f Procfile -e Procfile.env
README

## DB
file 'config/database.yml', <<-DATABASE
development:
  adapter: postgresql
  encoding: unicode
  database: #{@app_name}_development
  pool: 5

test:
  adapter: postgresql
  encoding: unicode
  database: #{@app_name}_test
  pool: 5

production:
  adapter: postgresql
  encoding: unicode
  database: #{@app_name}_production
  pool: 5
DATABASE

## Foreman
create_file 'Procfile', 'web: rails s -e production'
create_file 'Procfile.dev', 'web: rails s'
create_file 'Procfile.dev.env', ''
create_file 'Procfile.test.env', ''

devise = yes?("Devise?")
devise_model = ask("What should we name your devise model?") if devise

## GEMS
gem 'foreman'
gem 'slim-rails'
gem 'devise' if devise
gem 'foundation-rails'
gem_group :development, :test do
  gem 'rspec-rails'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'poltergeist'
end

# bundle
run 'bundle install'

# Generators
generate 'rspec:install'
generate 'foundation:install --slim'

## Devise
if devise
  generate 'devise:install'
  generate 'devise User'
  rake("db:migrate")
  rake("db:migrate RAILS_ENV=test")
  environment 'config.action_mailer.default_url_options = {host: "http://localhost:3000"}', env: 'development'
  generate :controller, "home index"
  route "root to: 'home#index'"
end

## git
git :init
git add: '.'
git commit: %Q{ -m 'Initial commit' }
