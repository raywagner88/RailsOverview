class Post < ApplicationRecord
  has_many :comments

  belongs_to :user

  scope :by_user, ->(id) do
    where(user_id: id) if id
  end
end
