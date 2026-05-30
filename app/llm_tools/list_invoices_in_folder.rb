module LlmTools
  class ListInvoicesInFolder < BaseTool
    description "List all invoices contained in a specific folder owned by the current user."

    param :folder_id, type: :integer, desc: "ID of the folder"

    def execute(folder_id:)
      folder = user.folders.find_by(id: folder_id)
      return { error: "Folder ##{folder_id} not found" } unless folder

      {
        folder: { id: folder.id, name: folder.name },
        invoices: folder.invoices.map do |i|
          {
            id: i.id,
            company_name: i.company_name,
            amount: i.amount,
            category: i.category,
            status: i.status,
            due_date: i.due_date
          }
        end
      }
    end
  end
end
