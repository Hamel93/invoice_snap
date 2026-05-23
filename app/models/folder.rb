class Folder < ApplicationRecord
  belongs_to :user

  has_many :folder_invoices, dependent: :destroy
  has_many :invoices, through: :folder_invoices

  validates :name, presence: true
end
