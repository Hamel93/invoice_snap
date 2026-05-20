class FolderInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :folder
  belongs_to :invoice, optional: true
end
