class User < ApplicationRecord

  scope :search, -> (email) { where("email ILIKE ?" , "%#{email}%")}
end