module LlmTools
  class SpendingSummary < BaseTool
    description <<~DESC
      Aggregate the user's invoice amounts, grouped by category, status, month, or company.
      Optionally restrict to a date range on due_date.
    DESC

    param :group_by,
          desc: "One of: 'category', 'status', 'month', 'company'"
    param :date_from,
          desc: "Restrict to invoices with due_date on or after this date (YYYY-MM-DD)",
          required: false
    param :date_to,
          desc: "Restrict to invoices with due_date on or before this date (YYYY-MM-DD)",
          required: false

    def execute(group_by:, date_from: nil, date_to: nil)
      scope = user.invoices
      scope = scope.where("due_date >= ?", Date.parse(date_from)) if date_from.present?
      scope = scope.where("due_date <= ?", Date.parse(date_to)) if date_to.present?

      groups =
        case group_by
        when "category" then scope.group(:category)
        when "status"   then scope.group(:status)
        when "company"  then scope.group(:company_name)
        when "month"    then scope.group("DATE_TRUNC('month', due_date)")
        else
          return { error: "Invalid group_by '#{group_by}'. Must be 'category', 'status', 'month', or 'company'." }
        end

      totals = groups.sum(:amount)
      counts = groups.count

      {
        group_by: group_by,
        total: scope.sum(:amount).to_f,
        invoice_count: scope.count,
        groups: totals.map { |key, total| { key: key.to_s, total: total.to_f, count: counts[key] } }
      }
    rescue ArgumentError => e
      { error: "Invalid date: #{e.message}" }
    end
  end
end
