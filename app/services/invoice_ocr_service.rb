require "net/http"
require "json"
require "base64"

class InvoiceOcrService
  OCR_SPACE_URL = "https://api.ocr.space/parse/image".freeze

  def initialize(invoice)
    @invoice = invoice
  end

  def call
    return unless @invoice.document.attached?

    raw_text = extract_text_from_document
    return if raw_text.blank?

    @invoice.update(
      company_name: detect_company_name(raw_text),
      invoice_number: detect_invoice_number(raw_text),
      amount: detect_amount(raw_text),
      due_date: detect_due_date(raw_text),
      category: @invoice.category.presence || "OCR",
      ocr_extracted_text: raw_text
    )
  rescue StandardError => e
    Rails.logger.error("OCR failed for invoice #{@invoice.id}: #{e.message}")
    @invoice.update(ocr_extracted_text: "OCR failed: #{e.message}")
  end

  private

  def extract_text_from_document
    api_key = ENV.fetch("OCR_SPACE_API_KEY")

    blob = @invoice.document.blob
    file_data = @invoice.document.download
    base64_file = Base64.strict_encode64(file_data)

    uri = URI(OCR_SPACE_URL)

    response = Net::HTTP.post_form(
      uri,
      {
        apikey: api_key,
        language: "fre",
        isOverlayRequired: "false",
        OCREngine: "2",
        base64Image: "data:#{blob.content_type};base64,#{base64_file}"
      }
    )

    json = JSON.parse(response.body)

    if json["IsErroredOnProcessing"]
      raise json["ErrorMessage"].to_s
    end

    json.dig("ParsedResults", 0, "ParsedText").to_s.strip
  end

  def detect_company_name(text)
    first_line = text.lines.map(&:strip).reject(&:blank?).first
    first_line.presence || @invoice.company_name
  end

  def detect_invoice_number(text)
    patterns = [
      /invoice\s*(number|no|#)?\s*[:\-]?\s*([A-Z0-9\-]+)/i,
      /facture\s*(numéro|no|#)?\s*[:\-]?\s*([A-Z0-9\-]+)/i,
      /no\.?\s*[:\-]?\s*([A-Z0-9\-]+)/i
    ]

    patterns.each do |pattern|
      match = text.match(pattern)
      return match.captures.compact.last if match
    end

    @invoice.invoice_number
  end

  def detect_amount(text)
    money_matches = text.scan(/\d+[,.]\d{2}/)
    return @invoice.amount if money_matches.empty?

    money_matches.map { |value| value.tr(",", ".").to_f }.max
  end

  def detect_due_date(text)
    match = text.match(/\b(\d{4}[-\/]\d{2}[-\/]\d{2}|\d{2}[-\/]\d{2}[-\/]\d{4})\b/)
    return @invoice.due_date unless match

    Date.parse(match[1]) rescue @invoice.due_date
  end
end
