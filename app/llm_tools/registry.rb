module LlmTools
  class Registry
    TOOL_CLASSES = [
      SearchInvoices,
      GetInvoice,
      ListFolders,
      ListInvoicesInFolder,
      GetOcrText,
      SpendingSummary,
      CreateReminder,
      MarkInvoiceAsPaid,
      CategorizeInvoice,
      MoveInvoiceToFolder,
      CreateFolder
    ].freeze

    def self.all_for(user)
      TOOL_CLASSES.map { |klass| klass.new(user) }
    end
  end
end
