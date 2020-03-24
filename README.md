## Install Ruby + Rails
This guide will provide steps to setup Ruby as well as install Ruby on Rails for various operating systems.
https://gorails.com/setup/osx/10.15-catalina
The guide recommends that you install Ruby 2.7 do not do this, instead install Ruby 2.6.5. Ruby 2.7 seems to have some issues with ROR so if you accidentally install it you may have issues.
The guide provides some options for installing databases, in this case we're going to install PostgreSQL.

## Create Rails Project
The following command will scaffold a basic RoR project as an API only and configure a Postgresql DB.
`rails new my-project-name --api --database=postgresql`
You'll then run the command `rails db:create`. This will initialize the databse for rails and run any migrations.

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
Rails has some super handy generators in the CLI to help build resources swiftly. Let's run the following command.
`rails generate scaffold Post content:text`
This is going to create a whole bunch of files that don't make sense but we'll go through them all.

Let's start with the following file, your file probably has a different timestamp though so it may look a but different.
```ruby
# db/migrate/20200322143345_create_posts.rb
class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :content

      t.timestamps
    end
  end
end
```
This is a migration file that is going to create a table in our database called `posts` with 4 attributes. `id`, `content`, `updated_at`, `created_at`. Let's jump back to our console and run `rails db:migrate` this may take a minute but you'll see another file appear in the `db` directory called `schema.rb`. If you take a look at that file you should see the following table being created.
```ruby
create_table "posts", force: :cascade do |t|
  t.text "content"
  t.datetime "created_at", precision: 6, null: false
  t.datetime "updated_at", precision: 6, null: false
end
```

There is also a file that was generated that Rails uses to model the data in our database so we can interact with is.
```ruby
# app/models/post.rb
class Post < ApplicationRecord
end

```
Notice there's nothing here yet but we'll be adding some things in the future.

Rails comes with a handy development environement for interacting with the database using ruby. In the console run `rails c`. Once the development environment loads run the following to connect to the database `Post.connection`, this will spit out a bunch of nonsense, just ignore it as it's initializing the connection with the databse.

Now we can write some code! Run the following command to create our first resource.
```ruby
post = Post.new(content: 'This is some text in my post')
```
This is calling our `Post` model and giving the content attribute a value.
Notice that the console outputs some information when we press enter. It's returning the entire value of the Post model, some values are `nil` like `id`, `updated_at` and `created_at` these are all values that Rails will handle for us once we save the model. Go ahead and run the following.
```ruby
post.save
```
You should see and output of SQL that is making the insert into the posts table.
Now if you run `pp post` you should see that the attributes that were `nil` now have values.

Go ahead and create a couple of different posts in our database so we have some data to play with.

Now that we have some data you can search for all the posts. Run the following.
```ruby
Post.all
```
This will return you a collection of all the posts you've created.

If you wanted to find a single post you can do.
```ruby
Post.find(2)
```
This will search for a post with the id of 2.
If we want to change the content of one of the posts we can run the following.
```ruby
Post.find(2).update(content: 'I did not like my original post')
```
Notice that you'll again see some SQL output showing that the post is being updated.
Now if you want to delete a post you can do the following.
```ruby
Post.find(2).destroy
```
Again you'll see the SQL output of the post being deleted, and if you try to use the find method you'll get an error.

So that covers some basic operations with Rails' ActiveRecord ORM, more information on ActiveRecord can be found here. https://guides.rubyonrails.org/active_record_basics.html

Let's take a quick look at the routes file.
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :posts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```
Notice that the generator has already added our route for us. This tells rails that we have a route called posts and it now knows to look for the route actions in a `posts_controller.rb` file. Notice there's a link in the file to more information on routing, feel free to dig in deeper as routing can be very powerful in rails.

Jump back to your console real quick, exit the ruby development environment if you're still in it by typeing exit and then enter.

Now run the command `rails routes`, notice at the top of the output you'll see our routes for posts and the url needed.

Now lets jump to the controller where the routes are pointing.

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    if @post.save
      render :show, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    if @post.update(post_params)
      render :show, status: :ok, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:content)
    end
end
```

This may be somewhat overwhelming to look at to start. But it's just doing everything this we did in the console. You'll notice that you have an `index`, `show`, `create`, `update`, and `destroy` actions that were defined in the route output. Also notice that some of the methods we used in the ruby development enviroment are here in the actions.

There's also a `before_action` called `set_post` which is calling the private method in our controller called `set_post`. Notice in set post that it's calling `Post.find(params[:id])` and assigning it to a varaible with an odd `@` symbol, this is called an instance variable in ruby and it allows the variable to be used throughout all the methods in the class. Without the `@` symbol the above actions wouldn't be able to access that variable. Additionally, there's the `params[:id]` this is how Rails allows you to access the parameters being passed to the controller.

You'll see the `render` method being called in some of the controllers as well. Let's look at the create action for example.
```ruby
def create
  @post = Post.new(post_params)

  if @post.save
    render :show, status: :created, location: @post
  else
    render json: @post.errors, status: :unprocessable_entity
  end
end
```

There's an if/else statement that says if the post is successfully saved then `render :show, status: :created, location: @post`, this takes us to the view that the controller is calling. In this case you don't actually see anything because we're just creating an api so the view in our case is just creating a json response.

```ruby
# app/views/posts/show.json.jbuilder
json.partial! "posts/post", post: @post

```
When we called render show this is the file that it's pointing to. Which is actually just calling a partial called `post`. A partial is reusable code that the view can use over and over again. So lets look at the partial.
```ruby
# app/views/posts/_post.json.jbuilder

json.extract! post, :id, :content, :created_at, :updated_at
json.url post_url(post, format: :json)
```
The first line is really what we want to look at here, this shows what parameters we want to include from the post in our response.

Take a look at the `app/views/posts/index.json.jbuilder` file. Notice here that it's declaring the response to be an array and using the same partial file to format each post for us.

This covered the Model View Controller of Rails. Let's fire up our program and test it out.

Go back to your terminal and run `rails s`

Open up another terminal windo and run `curl localhost:3000/posts` this will hit the index action and return all the posts. If you run curl localhost:3000/posts/1` it will hit the show action and return just the one post. You can see the Rails will output logs for you that show the parameters being passed as well as the queries being made and the files that are being used.

## Comments

Now we'll create the comments that go along with our posts.

Run the following in your terminal. `rails generate scaffold Comment post:references content:text`

Go ahead and check out the migration file that was created for this.
```ruby
class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
```
Notice that it's going to create a references column, this is going to reference the ID of the post. Run `rails db:migrate` and notice that a `post_id` is created in our schema on the comments table.

Take a look at the Comment model.
```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
end
```
Notice that here there is some code in the Content model, this is setting up the relationship with the Post model. Jump to your post model and add the following code to setup the relationship to the comment.
```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
end
```

Let's jump back to the ruby development environment by running `rails c`

Let's create a comment now by doing the following.

```ruby
comment = Comment.new(post_id: 1, content: 'I did not like your post')
comment.save
```

Because of the relationships in Rails we can now do this to get to the post.
```ruby
Comment.find(1).post
```
We should now see the post that is associated with the comment. We can do the opposite from the post.
```ruby
Post.find(1).comments
```
Notice that this will return an array of all the comments associated with the post.

Again the controller is setup for you as well as the views for comments.

## Scopes

Rails allows us to build scopes on the models so we can narrow down our data better.

Jump back to the Comment model and add the following code.

```ruby
class Comment < ApplicationRecord
  belongs_to :post

  scope :by_post, ->(id) do
    where(post_id: id)
  end
end
```
This is using a lamda to create a scope for us to search only comments with a certain post id.

In your ruby development environment type `reload!` to update the values and then do the following.

```ruby
Comment.by_post(1)
```

This should now return all comments that have a post_id of 1. Let's add this code to our index action on the controller.

```ruby
def index
  @comments = Comment.by_post(params[:post_id])
end
```

Now just back to your terminal and execute a curl requst like so.
```bash
curl 'localhost:3000/comments?post_id=1'
```

This will only return the comments associated with the post with an id of 1.

Do the same thing with different post ids and noticet that nothing will come through because we haven't created any comments. Feel free to create some additional comments in either the ruby development environment or with curl or postman.

## Advanced Topic
I'll leave this for you guys to attempt to figure out if you want.
There's a very popular gem available called Devise that implements a secure authentication system using users and sessions. Because this is an api sessions aren't available but a spinoff gem was created to handle it via tokens. Check out the documents here https://github.com/lynndylanhurley/devise_token_auth.

In this case you'll want to follow the setup guide to add Devise Token Auth to our api as well as create migrations to reference comments and posts to the user.

Good luck, I'm always available on Slack to answer questions.
