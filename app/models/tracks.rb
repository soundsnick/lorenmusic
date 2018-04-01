class Tracks < ApplicationRecord
  def self.search(title)
    if title
      where(title: "#{title.downcase}").take
    end
  end
end