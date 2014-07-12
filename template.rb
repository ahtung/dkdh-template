# template.rb

# README
remove_file "app/views/layouts/application.html.erb"

remove_file "README.rdoc"
file 'README.md', <<-CODE
# #{@app_name}

## Development

``` foreman start -f Procfile.dev -e Procfile.dev.env  ```

## Test

``` foreman run rspec -e Procfile.test.env  ```

CODE

remove_file "db/database.yml"
file 'db/database.yml', <<-CODE
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
CODE

create_file "Procfile.dev", "web: rails s"
create_file "Procfile.dev.env", ""
create_file "Procfile.test.env", ""

devise = yes?("Devise?")
devise_model = ask("What should we name your devise model?") if devise

# GEMS
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

# devise
if devise
  generate 'devise:install'
  generate 'devise User'
  rake("db:migrate")
  rake("db:migrate RAILS_ENV=test")
  environment 'config.action_mailer.default_url_options = {host: "http://localhost:3000"}', env: 'development'
  generate :controller, "home index"
  route "root to: 'home#index'"
end

# git
git :init
git add: '.'
git commit: %Q{ -m 'Initial commit' }
