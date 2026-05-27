class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_many :invoices, dependent: :destroy
  has_many :folders, dependent: :destroy
  has_many :chats, dependent: :destroy
end
