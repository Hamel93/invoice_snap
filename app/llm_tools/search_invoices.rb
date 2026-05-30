module LlmTools
  class SearchInvoices < BaseTool
    description <<~DESC
      Search the current user's invoices with optional filters.
      Returns a list of invoices with their key fields.
    DESC

    param :status,
          desc: "Filter by status: 'pending', 'paid', or 'overdue'",
          required: false
    param :category,
          desc: "Filter by category (substring match, case-insensitive)",
          required: false
    param :company_name,
          desc: "Filter by company name (substring match, case-insensitive)",
          required: false
    param :due_from,
          desc: "Filter invoices with due_date on or after this date (YYYY-MM-DD)",
          required: false
    param :due_to,
          desc: "Filter invoices with due_date on or before this date (YYYY-MM-DD)",
          required: false
    param :min_amount,
          type: :number,
          desc: "Minimum amount (inclusive)",
          required: false
    param :max_amount,
          type: :number,
          desc: "Maximum amount (inclusive)",
          required: false
    param :limit,
          type: :integer,
          desc: "Maximum number of results (default 50)",
          required: false

    def execute(status: nil, category: nil, company_name: nil,
                due_from: nil, due_to: nil,
                min_amount: nil, max_amount: nil, limit: nil)
      scope = user.invoices
      scope = scope.where(status: status) if status.present?
      scope = scope.where("category ILIKE ?", "%#{category}%") if category.present?
      scope = scope.where("company_name ILIKE ?", "%#{company_name}%") if company_name.present?
      scope = scope.where("due_date >= ?", Date.parse(due_from)) if due_from.present?
      scope = scope.where("due_date <= ?", Date.parse(due_to)) if due_to.present?
      scope = scope.where("amount >= ?", min_amount) if min_amount
      scope = scope.where("amount <= ?", max_amount) if max_amount

      invoices = scope.order(due_date: :desc).limit(limit || 50)

      {
        count: invoices.size,
        invoices: invoices.map { |i| serialize(i) }
      }
    rescue ArgumentError => e
      { error: "Invalid date: #{e.message}" }
    end

    private

    def serialize(invoice)
      {
        id: invoice.id,
        company_name: invoice.company_name,
        amount: invoice.amount,
        category: invoice.category,
        due_date: invoice.due_date,
        status: invoice.status,
        invoice_number: invoice.invoice_number
      }
    end
  end
end
