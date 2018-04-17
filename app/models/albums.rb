class Albums < ApplicationRecord

  scope :search, -> (title) { where("email ILIKE ?" , "%#{title}%")}
  scope :searchByAuthor, -> (user_id) { where(author: user_id)}
end