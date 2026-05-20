class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def dashboard
    @invoices = current_user.invoices
    @folders = current_user.folders.distinct

    @reminders = Reminder.joins(:invoice)
                         .where(invoices: { user_id: current_user.id })
  end
end
