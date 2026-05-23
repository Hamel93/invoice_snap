class Invoice < ApplicationRecord
  belongs_to :user

  has_many :folder_invoices, dependent: :destroy
  has_many :folders, through: :folder_invoices
  has_many :reminders, dependent: :destroy

  has_one_attached :document

  validates :company_name, presence: true

  validates :amount,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :status,
            inclusion: {
              in: %w[pending paid overdue]
            },
            allow_blank: true

  validate :acceptable_document

  private

  def acceptable_document
    return unless document.attached?

    unless document.byte_size <= 10.megabytes
      errors.add(:document, "est trop lourd (maximum 10MB)")
    end

    accepted_types = [
      "application/pdf",
      "image/png",
      "image/jpeg",
      "image/jpg"
    ]

    unless accepted_types.include?(document.content_type)
      errors.add(
        :document,
        "doit être un PDF, JPG ou PNG"
      )
    end
  end
end
