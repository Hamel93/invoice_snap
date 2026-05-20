class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_many :invoices, dependent: :destroy

  has_many :folder_invoices, dependent: :destroy
  has_many :folders, through: :folder_invoices
end
