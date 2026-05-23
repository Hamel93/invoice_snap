class Reminder < ApplicationRecord
  belongs_to :invoice

  validates :reminder_date, presence: true
end
