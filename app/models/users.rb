class Users < ApplicationRecord
  def self.search(email)
    if email
      where(email: "#{email.downcase}").take
    end
  end
end