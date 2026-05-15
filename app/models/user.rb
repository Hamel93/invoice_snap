class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable

  has_many :invoices, dependent: :destroy
  has_many :folder_invoices, dependent: :destroy
end
