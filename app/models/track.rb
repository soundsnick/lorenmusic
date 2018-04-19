class Track < ApplicationRecord

  scope :search, -> (title) { where("title ILIKE ?" , "%#{title}%")}
  scope :searchByAuthor, -> (userId) { where(author: userId)}
end