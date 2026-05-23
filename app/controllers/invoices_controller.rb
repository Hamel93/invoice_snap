class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show edit update destroy]

  def index
    @invoices = current_user.invoices.order(created_at: :desc)
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
          FolderInvoice.create(user: current_user, invoice: @invoice, folder_id: folder_id)
        end
      end
      redirect_to invoice_path(@invoice), notice: "Facture enregistrée."
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
      redirect_to invoice_path(@invoice), notice: "Facture mise à jour."
    else
      @folders = current_user.folders.distinct
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Facture supprimée."
  end

  def search
    @query = params[:q].to_s.strip
    scope  = current_user.invoices.order(created_at: :desc)
    @invoices =
      if @query.present?
        scope.where("company_name ILIKE :q OR invoice_number ILIKE :q OR category ILIKE :q", q: "%#{@query}%")
      else
        scope
      end
  end

  def camera
  end

  def scan
    redirect_to new_invoice_path
  end

  private

  def set_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :company_name,
      :invoice_number,
      :amount,
      :due_date,
      :status,
      :category,
      :ocr_extracted_text,
      :document
    )
  end
end
