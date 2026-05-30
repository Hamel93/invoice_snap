module LlmTools
  class MoveInvoiceToFolder < BaseTool
    description "Add an invoice to a folder. Does not remove the invoice from other folders."

    param :invoice_id, type: :integer, desc: "ID of the invoice"
    param :folder_id, type: :integer, desc: "ID of the target folder"

    def execute(invoice_id:, folder_id:)
      invoice = user.invoices.find_by(id: invoice_id)
      return { error: "Invoice ##{invoice_id} not found" } unless invoice

      folder = user.folders.find_by(id: folder_id)
      return { error: "Folder ##{folder_id} not found" } unless folder

      if invoice.folders.include?(folder)
        return {
          success: true,
          message: "Invoice already in folder",
          invoice_id: invoice.id,
          folder_id: folder.id
        }
      end

      invoice.folders << folder
      { success: true, invoice_id: invoice.id, folder_id: folder.id, folder_name: folder.name }
    end
  end
end
