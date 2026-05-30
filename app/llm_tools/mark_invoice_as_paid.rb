module LlmTools
  class MarkInvoiceAsPaid < BaseTool
    description "Mark a specific invoice as paid."

    param :invoice_id, type: :integer, desc: "ID of the invoice"

    def execute(invoice_id:)
      invoice = user.invoices.find_by(id: invoice_id)
      return { error: "Invoice ##{invoice_id} not found" } unless invoice

      if invoice.update(status: "paid")
        { success: true, invoice_id: invoice.id, status: invoice.status }
      else
        { error: invoice.errors.full_messages.to_sentence }
      end
    end
  end
end
