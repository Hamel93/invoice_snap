class CreateFolderInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :folder_invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :folder, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
