puts "Cleaning database..."

Reminder.destroy_all
FolderInvoice.destroy_all
Folder.destroy_all
Invoice.destroy_all
User.destroy_all

puts "Creating users..."

user = User.create!(
  email: "demo@invoicesnap.com",
  password: "password123"
)

puts "Creating folders..."

utilities_folder = Folder.create!(
  name: "Utilities",
  user: user
)

business_folder = Folder.create!(
  name: "Business",
  user: user
)

personal_folder = Folder.create!(
  name: "Personal",
  user: user
)

puts "Creating invoices..."

invoice_1 = Invoice.create!(
  company_name: "Hydro Quebec",
  invoice_number: "HQ-2026-001",
  amount: 189.45,
  due_date: Date.today + 7.days,
  status: "pending",
  category: "Electricity",
  user: user
)

invoice_2 = Invoice.create!(
  company_name: "Videotron",
  invoice_number: "VID-2026-002",
  amount: 124.99,
  due_date: Date.today - 3.days,
  status: "overdue",
  category: "Internet",
  user: user
)

invoice_3 = Invoice.create!(
  company_name: "Amazon Web Services",
  invoice_number: "AWS-2026-003",
  amount: 542.10,
  due_date: Date.today + 14.days,
  status: "pending",
  category: "Cloud",
  user: user
)

invoice_4 = Invoice.create!(
  company_name: "Apple",
  invoice_number: "APL-2026-004",
  amount: 89.99,
  due_date: Date.today - 10.days,
  status: "paid",
  category: "Software",
  user: user
)

puts "Connecting invoices to folders..."

FolderInvoice.create!(
  folder: utilities_folder,
  invoice: invoice_1
)

FolderInvoice.create!(
  folder: utilities_folder,
  invoice: invoice_2
)

FolderInvoice.create!(
  folder: business_folder,
  invoice: invoice_3
)

FolderInvoice.create!(
  folder: personal_folder,
  invoice: invoice_4
)

puts "Creating reminders..."

Reminder.create!(
  invoice: invoice_1,
  reminder_date: Date.today + 5.days,
  sent: false
)

Reminder.create!(
  invoice: invoice_2,
  reminder_date: Date.today,
  sent: false
)

puts "Seeds created successfully!"
puts "Demo user:"
puts "Email: demo@invoicesnap.com"
puts "Password: password123"
