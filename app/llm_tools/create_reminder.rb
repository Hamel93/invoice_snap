module LlmTools
  class CreateReminder < BaseTool
    description "Schedule a reminder for a specific invoice on a given date."

    param :invoice_id, type: :integer, desc: "ID of the invoice"
    param :date, desc: "Reminder date (YYYY-MM-DD)"

    def execute(invoice_id:, date:)
      invoice = user.invoices.find_by(id: invoice_id)
      return { error: "Invoice ##{invoice_id} not found" } unless invoice

      reminder = invoice.reminders.create(reminder_date: Date.parse(date), sent: false)

      if reminder.persisted?
        {
          success: true,
          reminder_id: reminder.id,
          invoice_id: invoice.id,
          date: reminder.reminder_date
        }
      else
        { error: reminder.errors.full_messages.to_sentence }
      end
    rescue ArgumentError => e
      { error: "Invalid date: #{e.message}" }
    end
  end
end
