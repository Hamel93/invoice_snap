module ApplicationHelper
  # status key => [css modifier, French label]
  STATUS_MAP = {
    "paid" => ["paid", "Payée"],
    "payee" => ["paid", "Payée"],
    "pending" => ["pending", "En attente"],
    "overdue" => ["overdue", "En retard"],
    "signed" => ["neutral", "Signé"],
    "accepted" => ["paid", "Accepté"],
    "draft" => ["neutral", "Brouillon"],
    "archived" => ["neutral", "Archivée"]
  }.freeze

  FR_DAYS   = %w[dimanche lundi mardi mercredi jeudi vendredi samedi].freeze
  FR_MONTHS = [nil, "janvier", "février", "mars", "avril", "mai", "juin",
               "juillet", "août", "septembre", "octobre", "novembre", "décembre"].freeze
  FR_MONTHS_SHORT = [nil, "jan.", "fév.", "mars", "avr.", "mai", "juin",
                     "juil.", "août", "sept.", "oct.", "nov.", "déc."].freeze

  def status_badge(status)
    klass, label = status_meta(status)
    content_tag(:span, label, class: "badge-status #{klass}")
  end

  def status_class(status)
    status_meta(status).first
  end

  def status_label(status)
    status_meta(status).last
  end

  def eur(amount)
  number_to_currency(
    amount || 0,
    unit: "$",
    separator: ".",
    delimiter: " ",
    format: "%u%n",
    precision: 2
  )
end# Deterministic avatar tint based on a name ("" = default lilac/primary).
  def avatar_color_for(text)
    %w[default ok warn danger neutral][text.to_s.bytes.sum % 5].sub("default", "")
  end

  def initials(text)
    text.to_s.strip[0, 1].to_s.upcase.presence || "?"
  end

  # 2 400 $  /  2 400,50 $  (non-breaking spaces so the amount never wraps)
  def eur(amount)
    number_to_currency(
      amount || 0,
      unit: "$",
      separator: ",",
      delimiter: " ",
      format: "%n %u",
      precision: 2
    )
  end


  # "Lundi 19 mai 2025"
  def fr_date(date = Date.today)
    d = date.to_date
    "#{FR_DAYS[d.wday].capitalize} #{d.day} #{FR_MONTHS[d.month]} #{d.year}"
  end

  # "19 mai"
  def short_date(date)
    return "—" if date.blank?

    d = date.to_date
    "#{d.day} #{FR_MONTHS_SHORT[d.month]}"
  end

  def short_date(date)
    return "—" if date.blank?

    d = date.to_date
    "#{d.day} #{FR_MONTHS_SHORT[d.month]}"
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      tables: true,
      fenced_code_blocks: true
    )

    markdown.render(text).html_safe
  end

  private

  def status_meta(status)
    STATUS_MAP[status.to_s.downcase] || ["neutral", status.to_s.titleize.presence || "—"]
  end
end

