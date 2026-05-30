module LlmTools
  class GetInvoice < BaseTool
    description "Get the full detail of a specific invoice owned by the current user, including folders and reminders."

    param :invoice_id, type: :integer, desc: "ID of the invoice"

    def execute(invoice_id:)
      invoice = user.invoices.find_by(id: invoice_id)
      return { error: "Invoice ##{invoice_id} not found" } unless invoice

      {
        id: invoice.id,
        company_name: invoice.company_name,
        amount: invoice.amount,
        category: invoice.category,
        due_date: invoice.due_date,
        status: invoice.status,
        invoice_number: invoice.invoice_number,
        created_at: invoice.created_at,
        folder_ids: invoice.folder_ids,
        reminders: invoice.reminders.map do |r|
          { id: r.id, date: r.reminder_date, sent: r.sent }
        end
      }
    end
  end
end
