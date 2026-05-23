class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: %i[show edit update destroy]

  def index
    @reminders = Reminder.joins(:invoice)
                         .where(invoices: { user_id: current_user.id })
  end

  def show
  end

  def new
    @reminder = Reminder.new
    @invoices = current_user.invoices.order(created_at: :desc)
  end

  def create
    @reminder = Reminder.new(reminder_params)

    if @reminder.save
      redirect_to reminder_path(@reminder), notice: "Reminder created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @invoices = current_user.invoices.order(created_at: :desc)
  end

  def update
    if @reminder.update(reminder_params)
      redirect_to reminder_path(@reminder), notice: "Reminder updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reminder.destroy
    redirect_to reminders_path, notice: "Reminder deleted successfully."
  end

  private

  def set_reminder
    @reminder = Reminder.joins(:invoice)
                        .where(invoices: { user_id: current_user.id })
                        .find(params[:id])
  end

  def reminder_params
    params.require(:reminder).permit(
      :invoice_id,
      :reminder_date,
      :sent
    )
  end
end
