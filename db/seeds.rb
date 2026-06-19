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
user.folders.destroy_all

TODAY = Date.new(2026, 6, 18)

YEAR_FOLDERS = [2023, 2024, 2025, 2026].freeze
year_folders = YEAR_FOLDERS.index_with { |y| user.folders.create!(name: y.to_s) }

# Recurring monthly bills used to fill each past year with realistic history.
RECURRING = [
  { company: "Hydro-Québec",          category: "Hydro / Électricité", amount: 142.50, day: 5  },
  { company: "Bell Canada",           category: "Télécommunications",  amount: 89.99,  day: 8  },
  { company: "Vidéotron",             category: "Télécommunications",  amount: 64.95,  day: 12 },
  { company: "Loyer Immobilier",      category: "Logement",            amount: 1450.00, day: 1 },
  { company: "Netflix",               category: "Abonnements",         amount: 16.99,  day: 14 },
  { company: "Spotify",               category: "Abonnements",         amount: 10.99,  day: 20 },
  { company: "Desjardins Assurances", category: "Assurances",          amount: 78.40,  day: 22 },
  { company: "CPE Les Petits Loups",  category: "Enfants / Famille",   amount: 215.00, day: 3  }
].freeze

# Occasional purchases spread across the year (month → entries).
OCCASIONAL = {
   2 => [ { company: "Costco",        category: "Épicerie",         amount: 312.45 },
          { company: "Shell",         category: "Transport / Auto", amount: 68.20  } ],
   4 => [ { company: "Jean Coutu",    category: "Santé",            amount: 42.85  },
          { company: "IGA",           category: "Épicerie",         amount: 184.30 } ],
   6 => [ { company: "RONA",          category: "Maison",           amount: 256.75 } ],
   8 => [ { company: "Esso",          category: "Transport / Auto", amount: 71.40  },
          { company: "Metro",         category: "Épicerie",         amount: 142.18 } ],
  10 => [ { company: "Canac",         category: "Maison",           amount: 489.00 },
          { company: "Familiprix",    category: "Santé",            amount: 28.50  } ],
  12 => [ { company: "IKEA",          category: "Maison",           amount: 612.30 },
          { company: "Amazon Prime",  category: "Abonnements",      amount: 79.99  } ]
}.freeze

invoice_counter = 0
build = ->(company:, category:, amount:, issued_on:, due_on:, status:, folder:, remind_on: nil) do
  invoice_counter += 1
  invoice = user.invoices.create!(
    company_name:       company,
    invoice_number:     "FA-#{issued_on.year}-#{format('%04d', invoice_counter)}",
    amount:             amount,
    status:             status,
    category:           category,
    due_date:           due_on,
    ocr_extracted_text: "#{company} — #{format('%.2f', amount)} $ CAD — émise le #{issued_on.strftime('%d/%m/%Y')}",
    created_at:         issued_on.to_time
  )
  FolderInvoice.create!(invoice: invoice, folder: folder)
  Reminder.create!(invoice: invoice, reminder_date: remind_on, sent: remind_on < TODAY) if remind_on
  invoice
end

# ---- Past years: fully paid history (2023, 2024, 2025) ----
[2023, 2024, 2025].each do |year|
  folder = year_folders[year]

  (1..12).each do |month|
    RECURRING.each do |bill|
      issued_on = Date.new(year, month, bill[:day])
      due_on    = issued_on + 14
      build.call(
        company:   bill[:company],
        category:  bill[:category],
        amount:    bill[:amount],
        issued_on: issued_on,
        due_on:    due_on,
        status:    "paid",
        folder:    folder
      )
    end

    Array(OCCASIONAL[month]).each do |entry|
      issued_on = Date.new(year, month, 15)
      build.call(
        company:   entry[:company],
        category:  entry[:category],
        amount:    entry[:amount],
        issued_on: issued_on,
        due_on:    issued_on + 7,
        status:    "paid",
        folder:    folder
      )
    end
  end
end

# ---- 2026: current year — paid + pending + overdue ----
folder_2026 = year_folders[2026]

# January → May 2026: recurring monthly bills already paid.
(1..5).each do |month|
  RECURRING.each do |bill|
    issued_on = Date.new(2026, month, bill[:day])
    due_on    = issued_on + 14
    build.call(
      company:   bill[:company],
      category:  bill[:category],
      amount:    bill[:amount],
      issued_on: issued_on,
      due_on:    due_on,
      status:    "paid",
      folder:    folder_2026
    )
  end

  Array(OCCASIONAL[month]).each do |entry|
    issued_on = Date.new(2026, month, 15)
    build.call(
      company:   entry[:company],
      category:  entry[:category],
      amount:    entry[:amount],
      issued_on: issued_on,
      due_on:    issued_on + 7,
      status:    "paid",
      folder:    folder_2026
    )
  end
end

# June 2026 (en cours) : Loyer + premières charges déjà payées.
[
  { company: "Loyer Immobilier",      category: "Logement",            amount: 1450.00, day: 1  },
  { company: "Hydro-Québec",          category: "Hydro / Électricité", amount: 138.20,  day: 5  },
  { company: "Bell Canada",           category: "Télécommunications",  amount: 89.99,   day: 8  }
].each do |bill|
  issued_on = Date.new(2026, 6, bill[:day])
  build.call(
    company:   bill[:company],
    category:  bill[:category],
    amount:    bill[:amount],
    issued_on: issued_on,
    due_on:    issued_on + 10,
    status:    "paid",
    folder:    folder_2026
  )
end

# ---- Factures à payer prochainement (status: pending, due_date dans le futur) ----
upcoming = [
  { company: "Vidéotron",             category: "Télécommunications",  amount: 64.95,   issued: Date.new(2026, 6, 12), due: Date.new(2026, 6, 22) },
  { company: "Netflix",               category: "Abonnements",         amount: 16.99,   issued: Date.new(2026, 6, 14), due: Date.new(2026, 6, 24) },
  { company: "Spotify",               category: "Abonnements",         amount: 10.99,   issued: Date.new(2026, 6, 15), due: Date.new(2026, 6, 25) },
  { company: "Desjardins Assurances", category: "Assurances",          amount: 78.40,   issued: Date.new(2026, 6, 10), due: Date.new(2026, 6, 28) },
  { company: "SAAQ",                  category: "Transport / Auto",    amount: 348.00,  issued: Date.new(2026, 6, 1),  due: Date.new(2026, 6, 30) },
  { company: "CPE Les Petits Loups",  category: "Enfants / Famille",   amount: 215.00,  issued: Date.new(2026, 6, 17), due: Date.new(2026, 7, 3)  },
  { company: "RONA",                  category: "Maison",              amount: 421.65,  issued: Date.new(2026, 6, 16), due: Date.new(2026, 7, 5)  },
  { company: "Jean Coutu",            category: "Santé",               amount: 56.30,   issued: Date.new(2026, 6, 13), due: Date.new(2026, 7, 8)  },
  { company: "Clinique Dentaire Plateau", category: "Santé",           amount: 285.00,  issued: Date.new(2026, 6, 11), due: Date.new(2026, 7, 11) },
  { company: "Hydro-Québec",          category: "Hydro / Électricité", amount: 156.40,  issued: Date.new(2026, 6, 18), due: Date.new(2026, 7, 18) }
]

upcoming.each do |entry|
  build.call(
    company:   entry[:company],
    category:  entry[:category],
    amount:    entry[:amount],
    issued_on: entry[:issued],
    due_on:    entry[:due],
    status:    "pending",
    folder:    folder_2026,
    remind_on: entry[:due] - 2
  )
end

# ---- Factures en retard (status: overdue, due_date passée) ----
overdue = [
  { company: "Bell Canada",           category: "Télécommunications",  amount: 89.99,  issued: Date.new(2026, 2, 8),  due: Date.new(2026, 2, 22) },
  { company: "Hydro-Québec",          category: "Hydro / Électricité", amount: 168.75, issued: Date.new(2026, 3, 5),  due: Date.new(2026, 3, 19) },
  { company: "Canac",                 category: "Maison",              amount: 612.40, issued: Date.new(2026, 4, 11), due: Date.new(2026, 5, 1)  },
  { company: "Vidéotron",             category: "Télécommunications",  amount: 64.95,  issued: Date.new(2026, 5, 12), due: Date.new(2026, 5, 26) },
  { company: "Garage Lafleur",        category: "Transport / Auto",    amount: 845.20, issued: Date.new(2026, 5, 2),  due: Date.new(2026, 5, 30) },
  { company: "Pharmacie Uniprix",     category: "Santé",               amount: 124.55, issued: Date.new(2026, 5, 20), due: Date.new(2026, 6, 5)  },
  { company: "École Saint-Joseph",    category: "Enfants / Famille",   amount: 320.00, issued: Date.new(2026, 5, 25), due: Date.new(2026, 6, 10) }
]

overdue.each do |entry|
  build.call(
    company:   entry[:company],
    category:  entry[:category],
    amount:    entry[:amount],
    issued_on: entry[:issued],
    due_on:    entry[:due],
    status:    "overdue",
    folder:    folder_2026
  )
end

# ---- Uber Eats : la plus grosse dépense du compte ----
# Commandes hebdomadaires sur 2024-2026 + une commande géante en décembre 2025.

UBER_FOLDERS = { 2024 => year_folders[2024], 2025 => year_folders[2025], 2026 => folder_2026 }.freeze

uber_orders_for_year = ->(year) do
  last_day = (year == 2026 ? TODAY : Date.new(year, 12, 31))
  orders = []
  cursor = Date.new(year, 1, 3)
  while cursor <= last_day
    # 2 commandes par semaine, jeudi soir + dimanche midi.
    [cursor + 3, cursor + 6].each do |order_date|
      next if order_date > last_day
      orders << { date: order_date, amount: [38.50, 42.90, 51.75, 47.20, 62.40, 56.80, 71.30, 49.95, 84.20, 59.40].sample }
    end
    cursor += 7
  end
  orders
end

[2024, 2025, 2026].each do |year|
  uber_orders_for_year.call(year).each do |order|
    build.call(
      company:   "Uber Eats",
      category:  "Restauration",
      amount:    order[:amount],
      issued_on: order[:date],
      due_on:    order[:date],
      status:    "paid",
      folder:    UBER_FOLDERS[year]
    )
  end
end

# Une poignée de grosses commandes de groupe (équipe, anniversaires).
[
  { date: Date.new(2024,  6, 14), amount: 287.50 },
  { date: Date.new(2024, 11,  8), amount: 312.80 },
  { date: Date.new(2025,  3, 21), amount: 264.40 },
  { date: Date.new(2025,  7, 18), amount: 398.60 },
  { date: Date.new(2025, 12, 20), amount: 2845.90 }, # Réception Noël équipe — la plus grosse facture du compte
  { date: Date.new(2026,  2, 13), amount: 412.30 },
  { date: Date.new(2026,  5,  9), amount: 356.75 }
].each do |order|
  build.call(
    company:   "Uber Eats",
    category:  "Restauration",
    amount:    order[:amount],
    issued_on: order[:date],
    due_on:    order[:date],
    status:    "paid",
    folder:    UBER_FOLDERS[order[:date].year]
  )
end

invoices_count = user.invoices.count
folders_count  = user.folders.count
reminders_count = Reminder.joins(:invoice).where(invoices: { user_id: user.id }).count
pending_count  = user.invoices.where(status: "pending").count
overdue_count  = user.invoices.where(status: "overdue").count
paid_count     = user.invoices.where(status: "paid").count

puts "✓ #{invoices_count} factures (#{paid_count} payées, #{pending_count} à payer, #{overdue_count} en retard)"
puts "✓ #{folders_count} classeurs (#{user.folders.pluck(:name).join(', ')})"
puts "✓ #{reminders_count} rappels"
puts "✓ Connexion : demo@invoicesnap.fr  /  password"
