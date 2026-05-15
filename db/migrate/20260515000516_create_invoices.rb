class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.string :company_name
      t.string :invoice_number
      t.decimal :amount
      t.date :due_date
      t.string :status
      t.text :ocr_extracted_text
      t.string :category
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
