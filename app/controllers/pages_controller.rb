class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:home]

  def home
    redirect_to dashboard_path if user_signed_in?
  end

  def dashboard
    @invoices = current_user.invoices.order(created_at: :desc)
    @folders = current_user.folders.order(:name)

    @total_invoices = @invoices.count
    @total_due = @invoices.where.not(status: "paid").sum(:amount)
    @overdue_invoices = @invoices.where("due_date < ? AND status != ?", Date.current, "paid")
    @upcoming_invoices = @invoices.where(due_date: Date.current..7.days.from_now.to_date)

    @reminders = Reminder.joins(:invoice)
                         .where(invoices: { user_id: current_user.id })
                         .order(reminder_date: :asc)
  end

  def profile
  end

  def notifications
    @invoices = current_user.invoices.order(due_date: :asc)
    @reminders = Reminder.joins(:invoice)
                         .where(invoices: { user_id: current_user.id })
                         .order(reminder_date: :asc)
  end
end
