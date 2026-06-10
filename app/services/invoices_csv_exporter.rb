require "csv"

class InvoicesCsvExporter
  HEADERS = [
    "Fournisseur",
    "N° facture",
    "Montant",
    "Date d'échéance",
    "Statut",
    "Catégorie",
    "Dossiers",
    "Créée le"
  ].freeze

  STATUS_LABELS = {
    "pending" => "En attente",
    "paid"    => "Payée",
    "overdue" => "En retard"
  }.freeze

  def initialize(invoices)
    @invoices = invoices
  end

  def to_csv
    csv_data = CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << HEADERS

      @invoices.includes(:folders).find_each do |invoice|
        csv << [
          invoice.company_name,
          invoice.invoice_number,
          format_amount(invoice.amount),
          invoice.due_date&.strftime("%d/%m/%Y"),
          STATUS_LABELS[invoice.status] || invoice.status,
          invoice.category,
          invoice.folders.map(&:name).join(" / "),
          invoice.created_at.strftime("%d/%m/%Y %H:%M")
        ]
      end
    end

    "﻿" + csv_data
  end

  private

  def format_amount(amount)
    return nil if amount.nil?

    format("%.2f", amount).tr(".", ",")
  end
end
