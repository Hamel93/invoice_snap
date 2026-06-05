class InvoiceAutoClassifierService
  CATEGORY_KEYWORDS = {
    "Facture" => ["facture", "invoice", "total", "montant", "paiement", "échéance", "due date"],
    "Reçu" => ["reçu", "receipt", "transaction", "achat", "tps", "tvq", "tax", "débit", "visa", "mastercard"],
    "Contrat" => ["contrat", "contract", "agreement", "signature", "conditions", "clause"],
    "Devis" => ["devis", "quote", "estimation", "soumission", "proposal"]
  }.freeze

  def initialize(invoice)
    @invoice = invoice
    @user = invoice.user
    @text = invoice.ocr_extracted_text.to_s.downcase
  end

  def call
    assign_year_folder
    assign_category_only
    assign_status
  end

  private

  def assign_year_folder
    year = extract_year
    return if year.blank?

    folder = @user.folders.find_or_create_by!(name: year)
    @invoice.folders << folder unless @invoice.folders.exists?(folder.id)
  end

  def assign_category_only
    @invoice.update(category: detect_category)
  end


  def assign_status
    return if @invoice.status.present? && @invoice.status != "pending"

    if paid_document?
      @invoice.update(status: "paid")
    elsif @invoice.due_date.present? && @invoice.due_date < Date.current
      @invoice.update(status: "overdue")
    else
      @invoice.update(status: "pending")
    end
  end

  def paid_document?
    paid_keywords = [
      "reçu", "receipt", "paid", "payé", "payee", "payment received",
      "transaction", "débit", "debit", "visa", "mastercard",
      "interac", "autorisé", "approved", "merci de votre achat"
    ]

    paid_keywords.any? { |keyword| @text.include?(keyword) }
  end

  def extract_year
    return @invoice.due_date.year.to_s if @invoice.due_date.present?

    match = @text.match(/\b(20\d{2})\b/)
    return match[1] if match

    @invoice.created_at.year.to_s
  end

  def detect_category
    CATEGORY_KEYWORDS.each do |category, keywords|
      return category if keywords.any? { |keyword| @text.include?(keyword) }
    end

    "Facture"
  end
end
