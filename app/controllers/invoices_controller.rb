class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show edit update destroy]

  def index
    @invoices = current_user.invoices.order(created_at: :desc)
    @query    = params[:q].to_s.strip

    if @query.present?
      @invoices = @invoices.where(
        "company_name ILIKE :q OR invoice_number ILIKE :q OR category ILIKE :q",
        q: "%#{@query}%"
      )
    end

    if params[:status].present? && params[:status] != "all"
      @invoices = @invoices.where(status: params[:status])
    end

    @status_filter = params[:status].presence || "all"

    respond_to do |format|
      format.html
      format.csv { send_csv_export }
    end
  end

  def show
  end

  def new
    @invoice = current_user.invoices.new
    @folders = current_user.folders.order(:name)
  end

  def create
    @invoice = current_user.invoices.new(invoice_params)

    Rails.logger.info("INVOICE CREATE PARAMS: #{params[:invoice].inspect}")

    if @invoice.save
      update_invoice_folders

      if @invoice.document.attached?
        Rails.logger.info("OCR START invoice_id=#{@invoice.id}")
        InvoiceOcrService.new(@invoice).call
        InvoiceAutoClassifierService.new(@invoice.reload).call
        Rails.logger.info("OCR END invoice_id=#{@invoice.id}")
      else
        Rails.logger.info("OCR SKIPPED no document invoice_id=#{@invoice.id}")
      end

      redirect_to invoice_path(@invoice), notice: "Facture créée avec succès."
    else
      Rails.logger.error("INVOICE CREATE FAILED: #{@invoice.errors.full_messages.join(', ')}")
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
    redirect_to invoices_path(q: params[:query].presence || params[:q])
  end

  def camera
  end

  def scan
    redirect_to new_invoice_path, notice: "OCR automatique disponible via le formulaire de création avec document."
  end

  private

  def send_csv_export
    send_data InvoicesCsvExporter.new(@invoices).to_csv,
              filename: "factures-#{Date.current.strftime('%Y-%m-%d')}.csv",
              type: "text/csv; charset=utf-8"
  end

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
