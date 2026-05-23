class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show edit update destroy]

  def index
    @invoices = current_user.invoices.order(created_at: :desc)
  end

  def show
  end

  def new
    @invoice = current_user.invoices.new
    @folders = current_user.folders.order(:name)
  end

  def create
    @invoice = current_user.invoices.new(invoice_params)

    if @invoice.save
      update_invoice_folders

      InvoiceOcrService.new(@invoice).call if @invoice.document.attached?

      redirect_to invoice_path(@invoice), notice: "Facture créée avec succès."
    else
      @folders = current_user.folders.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @folders = current_user.folders.order(:name)
  end

  def update
    if @invoice.update(invoice_params)
      update_invoice_folders
      redirect_to invoice_path(@invoice), notice: "Facture mise à jour avec succès."
    else
      @folders = current_user.folders.order(:name)
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
    redirect_to invoices_path, notice: "Facture supprimée avec succès."
  end

  def search
    @query = params[:query].to_s.strip

    @invoices = current_user.invoices
                            .where("company_name ILIKE ? OR invoice_number ILIKE ? OR category ILIKE ?", "%#{@query}%", "%#{@query}%", "%#{@query}%")
                            .order(created_at: :desc)

    render :index
  end

  def camera
  end

  def scan
    redirect_to new_invoice_path, notice: "OCR à venir. Pour le MVP, entre les informations manuellement."
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

  def update_invoice_folders
    return unless params[:invoice][:folder_ids]

    folder_ids = params[:invoice][:folder_ids].reject(&:blank?)
    folders = current_user.folders.where(id: folder_ids)

    @invoice.folders = folders
  end
end
