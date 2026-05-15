class Invoice < ApplicationRecord
  belongs_to :user

  has_many :folder_invoices, dependent: :destroy
  has_many :folders, through: :folder_invoices

  has_many :reminders, dependent: :destroy

  has_one_attached :document
end
