class Folder < ApplicationRecord
  has_many :folder_invoices, dependent: :destroy
  has_many :invoices, through: :folder_invoices
end
