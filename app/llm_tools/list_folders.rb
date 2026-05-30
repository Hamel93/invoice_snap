module LlmTools
  class ListFolders < BaseTool
    description "List all folders owned by the current user with their invoice count."

    def execute
      folders = user.folders.includes(:invoices)
      {
        count: folders.size,
        folders: folders.map do |f|
          { id: f.id, name: f.name, invoice_count: f.invoices.size }
        end
      }
    end
  end
end
