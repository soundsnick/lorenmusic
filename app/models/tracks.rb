class Tracks < ApplicationRecord

  scope :search, -> (title) { where("title ILIKE ?" , "%#{title}%")}
end