class CreateReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :reminders do |t|
      t.date :reminder_date
      t.boolean :sent
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
