module LlmTools
  class CategorizeInvoice < BaseTool
    description "Set or update the category of a specific invoice."

    param :invoice_id, type: :integer, desc: "ID of the invoice"
    param :category, desc: "Category name to assign"

    def execute(invoice_id:, category:)
      invoice = user.invoices.find_by(id: invoice_id)
      return { error: "Invoice ##{invoice_id} not found" } unless invoice

      if invoice.update(category: category)
        { success: true, invoice_id: invoice.id, category: invoice.category }
      else
        { error: invoice.errors.full_messages.to_sentence }
      end
    end
  end
end
