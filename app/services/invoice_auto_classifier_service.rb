class InvoiceAutoClassifierService
  CATEGORY_KEYWORDS = {
    "Factures" => [
      "facture", "invoice", "total", "montant", "paiement", "échéance", "due date"
    ],
    "Reçus" => [
      "reçu", "receipt", "transaction", "achat", "tps", "tvq", "tax", "débit", "visa", "mastercard"
    ],
    "Contrats" => [
      "contrat", "contract", "agreement", "signature", "conditions", "clause"
    ],
    "Devis" => [
      "devis", "quote", "estimation", "soumission", "proposal"
    ]
  }.freeze

  def initialize(invoice)
    @invoice = invoice
    @user = invoice.user
    @text = invoice.ocr_extracted_text.to_s.downcase
  end

  def call
    assign_year_folder
    assign_category_folder
  end

  private

  def assign_year_folder
    year = extract_year
    return if year.blank?

    folder = @user.folders.find_or_create_by!(name: year)
    @invoice.folders << folder unless @invoice.folders.exists?(folder.id)
  end

  def assign_category_folder
    category_name = detect_category
    return if category_name.blank?

    folder = @user.folders.find_or_create_by!(name: category_name)
    @invoice.folders << folder unless @invoice.folders.exists?(folder.id)

    @invoice.update(category: category_name)
  end

  def extract_year
    date = @invoice.due_date || @invoice.created_at
    return date.year.to_s if date.present?

    match = @text.match(/\b(20\d{2})\b/)
    match&.[](1)
  end

  def detect_category
    CATEGORY_KEYWORDS.each do |category, keywords|
      return category if keywords.any? { |keyword| @text.include?(keyword) }
    end

    "Factures"
  end
end
