require 'sinatra/base'
require 'json'
require_relative 'ledger'

module ExpenseTracker
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super
    end

    post '/expenses' do
      result = @ledger.record(JSON.parse(request.body.read))

      if result.success?
        JSON.generate({expense_id: result.expense_id})
      else
        status 422
        JSON.generate({error: result.error_message})
      end
    end

    get '/expenses/:date' do
      date = Date.parse(params[:date])

      JSON.generate(
        @ledger.records_at_date(date)
      )
    end
  end
end
