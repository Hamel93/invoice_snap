# Invoice Snap — demo data (idempotent).
# Run with:  bin/rails db:seed
# Login:     demo@invoicesnap.fr  /  password

puts "Seeding Invoice Snap demo data…"

user = User.find_or_initialize_by(email: "demo@invoicesnap.fr")
user.password = "password"
user.password_confirmation = "password"
user.save!

# Reset previous demo data so the seed stays idempotent.
user.invoices.destroy_all
FOLDER_NAMES = ["Factures", "Reçus", "Contrats", "Devis", "Archive 2024"].freeze
Folder.where(name: FOLDER_NAMES).destroy_all

folders = FOLDER_NAMES.index_with { |name| Folder.create!(name: name) }

invoices = [
  { company: "TechStartup SAS",     number: "FA-0125", amount: 1200, status: "pending",  category: "Prestation de service", folder: "Factures", created_ago: 2,   due_in: 18,  remind_in: 18 },
  { company: "TechStartup SAS",     number: "FA-0124", amount: 2400, status: "pending",  category: "Prestation de service", folder: "Factures", created_ago: 8,   due_in: 12,  remind_in: 12 },
  { company: "Design Studio Paris", number: "FA-0123", amount: 850,  status: "paid",     category: "Design",                folder: "Factures", created_ago: 14,  due_in: -2 },
  { company: "Agence Créative",     number: "FA-0122", amount: 3200, status: "overdue",  category: "Conseil",               folder: "Factures", created_ago: 22,  due_in: -9,  remind_in: -3 },
  { company: "Studio Lumière",      number: "FA-0121", amount: 1500, status: "paid",     category: "Photographie",          folder: "Factures", created_ago: 38 },
  { company: "Carrefour Pro",       number: "REC-0044", amount: 84,  status: "paid",     category: "Fournitures",           folder: "Reçus",    created_ago: 16 },
  { company: "SNCF",                number: "REC-0043", amount: 124, status: "paid",     category: "Déplacement",           folder: "Reçus",    created_ago: 44 },
  { company: "TechStartup SAS",     number: "DEV-0042", amount: 3500, status: "accepted", category: "Devis",                folder: "Devis",    created_ago: 30,  remind_in: 6 },
  { company: "TechStartup SAS",     number: "CT-2025",  amount: 0,    status: "signed",   category: "Contrat",              folder: "Contrats", created_ago: 70 },
  { company: "Freelance Network",   number: "FA-0120", amount: 980,  status: "paid",     category: "Prestation de service", folder: "Factures", created_ago: 62 },
  { company: "Agence Créative",     number: "FA-0119", amount: 1800, status: "paid",     category: "Conseil",               folder: "Archive 2024", created_ago: 96 },
  { company: "Design Studio Paris", number: "FA-0118", amount: 1450, status: "paid",     category: "Design",                folder: "Archive 2024", created_ago: 120 }
]

invoices.each do |d|
  invoice = user.invoices.create!(
    company_name:       d[:company],
    invoice_number:     d[:number],
    amount:             d[:amount],
    status:             d[:status],
    category:           d[:category],
    due_date:           (d[:due_in] ? Date.today + d[:due_in] : nil),
    ocr_extracted_text: "#{d[:company]} — #{d[:number]} — #{d[:amount]} € TTC",
    created_at:         d[:created_ago].days.ago
  )

  FolderInvoice.create!(user: user, invoice: invoice, folder: folders[d[:folder]])

  if d[:remind_in]
    Reminder.create!(invoice: invoice, reminder_date: Date.today + d[:remind_in], sent: d[:remind_in].negative?)
  end
end

puts "✓ #{user.invoices.count} factures, #{folders.size} classeurs, #{Reminder.joins(:invoice).where(invoices: { user_id: user.id }).count} rappels"
puts "✓ Connexion : demo@invoicesnap.fr  /  password"
