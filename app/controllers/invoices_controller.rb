class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show edit update destroy]

  def index
    @invoices = current_user.invoices
  end

  def show
  end

  def new
    @invoice = Invoice.new
    @folders = current_user.folders.distinct
  end

  def create
    @invoice = current_user.invoices.new(invoice_params)

    if @invoice.save

      if params[:invoice][:folder_ids].present?
        params[:invoice][:folder_ids].reject(&:blank?).each do |folder_id|
          FolderInvoice.create(
            user: current_user,
            invoice: @invoice,
            folder_id: folder_id
          )
        end
      end

      redirect_to invoice_path(@invoice), notice: "Invoice created successfully."
    else
      @folders = current_user.folders.distinct
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @folders = current_user.folders.distinct
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to invoice_path(@invoice), notice: "Invoice updated successfully."
    else
      @folders = current_user.folders.distinct
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Invoice deleted successfully."
  end

  def search
  end

  def camera
  end

  def scan
  end

  private

  def set_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :supplier,
      :invoice_number,
      :amount,
      :vat,
      :due_date,
      :status,
      :category,
      :extracted_text,
      :document
    )
  end
end
