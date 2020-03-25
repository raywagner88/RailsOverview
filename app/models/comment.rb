class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  scope :by_post, ->(id) do
    where(post_id: id) if id
  end

  scope :by_user, ->(id) do
    where(user_id: id) if id
  end
end
