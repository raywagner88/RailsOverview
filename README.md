## Install Ruby + Rails
This guide will provide steps to setup Ruby as well as install Ruby on Rails for various operating systems.
https://gorails.com/setup/osx/10.15-catalina
The guide recommends that you install Ruby 2.7 do not do this, instead install Ruby 2.6.5. Ruby 2.7 seems to have some issues with ROR so if you accidentally install it you may have issues.
The guide provides some options for installing databases, in this case we're going to install PostgreSQL.

## Create Rails Project
The following command will scaffold a basic RoR project as an API only and configure a Postgresql DB.
`rails new my-project-name --api --database=postgresql`
You'll then run the command `rake db:create`. This will initialize the databse for rails and run any migrations.

## Gemfile
This is very similar to your `package.json` file for node projects, instead of `node_modules` these are referred to as `gems`.
We'll need to uncomment out two gems that Rails provides for us.
```ruby
# Gemfile
gem 'jbuilder', '~> 2.7'
gem 'rack-cors'
```
Then run `bundle install` in your terminal to package everything up.

## CORS
Because we're building an api we'll need to prevent issues with cross origin resource sharing, I'm guessing some of you have run into this already with different apis already. Here's how it's handled in Rails.
Navigate to the following file `config/initializers/cors.rb`, you'll need to uncomment out all the lines and adjust your origing. For our case just set `origins '*'` which will allow any client to access the api.
The file should now look like the following.
```ruby
# config/initializers/cors.rb

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

## First Resource
We're going to create a super simple post and comment api where a user can make a post and other users can make comments on that post. Let's start with creating the posts resource.
Rails has some super handy generators in the CLI to help build resources swiftly. Let's run the following.
