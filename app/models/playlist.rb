class Playlist < ApplicationRecord

  scope :search, -> (userid) { where(author_id: userid)}
end