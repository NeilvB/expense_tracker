require 'rack/test'
require 'json'
require_relative '../../app/api'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API', :db do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    it 'records submitted expenses' do
      pending 'Need to have a way to persist expenses'

      coffee = post_expense(
        'payee' => 'Music and Beans',
        'amount' => 2.75,
        'date' => '2017-12-17'
      )

      zoo = post_expense(
        'payee' => 'Zoo',
        'amount' => 2.15,
        'date' => '2017-12-17'
      )

      groceries = post_expense(
        'payee' => 'Haringey Foods',
        'amount' => 5.75,
        'date' => '2017-12-27'
      )

      get '/expenses/2017-12-17'

      expect(last_response.status).to eq(200)
      expenses = JSON.parse(last_response.body)

      expect(expenses).to contain_exactly(coffee, zoo)
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      response_hash = JSON.parse(last_response.body)
      expect(response_hash).to include('expense_id' => a_kind_of(Integer))

      expense.merge('id' => response_hash['expense_id'])
    end
  end
end
