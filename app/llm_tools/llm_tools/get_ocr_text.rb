module LlmTools
  class GetOcrText < BaseTool
    description "Get the raw OCR-extracted text for a specific invoice. Use this when structured fields are not enough."

    param :invoice_id, type: :integer, desc: "ID of the invoice"

    def execute(invoice_id:)
      invoice = user.invoices.find_by(id: invoice_id)
      return { error: "Invoice ##{invoice_id} not found" } unless invoice

      {
        invoice_id: invoice.id,
        ocr_text: invoice.ocr_extracted_text.to_s
      }
    end
  end
end
