class InvoiceOcrService
  def initialize(invoice)
    @invoice = invoice
  end

  def call
    return unless @invoice.document.attached?

    extracted_data = fake_ocr_extraction

    @invoice.update(
      company_name: extracted_data[:company_name],
      invoice_number: extracted_data[:invoice_number],
      amount: extracted_data[:amount],
      due_date: extracted_data[:due_date],
      category: extracted_data[:category],
      ocr_extracted_text: extracted_data[:raw_text]
    )
  end

  private

  def fake_ocr_extraction
    {
      company_name: "OCR Demo Company",
      invoice_number: "OCR-2026-001",
      amount: 199.99,
      due_date: Date.today + 30.days,
      category: "OCR Scan",
      raw_text: <<~TEXT
        OCR DEMO EXTRACTION
        Invoice Number: OCR-2026-001
        Amount: 199.99
      TEXT
    }
  end
end
