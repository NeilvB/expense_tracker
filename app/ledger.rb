require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    def record(expense)
      missing_fields = ['payee', 'amount', 'date'].reject { |field| expense.key?(field) }

      unless missing_fields.empty?
        message = "Invalid expense: `#{missing_fields.join(" ")}` is required"
        return RecordResult.new(false, nil, message)
      end

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def records_at_date(date)
      DB[:expenses].where(date: date).all
    end
  end
end
