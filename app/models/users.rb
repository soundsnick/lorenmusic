class Users < ApplicationRecord

  scope :search, -> (email) { where("email ILIKE ?" , "%#{email}%")}
end