class RefactorFoldersArchitecture < ActiveRecord::Migration[8.1]
  def change
    remove_reference :folder_invoices, :user, foreign_key: true

    add_reference :folders, :user, null: false, foreign_key: true
  end
end
