class Comment < ApplicationRecord
  belongs_to :post

  scope :by_post, ->(id) do
    where(post_id: id)
  end
end
