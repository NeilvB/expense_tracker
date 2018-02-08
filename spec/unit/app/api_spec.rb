require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    def parsed_body
      JSON.parse(last_response.body)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger')}

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data'} }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          expect(parsed_body).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq 200
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data'} }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'BAD BOO BOO'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          expect(parsed_body).to include('error' => 'BAD BOO BOO')
        end

        it 'responds with 422 unprocessable entity' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq 422
        end
      end
    end

    describe 'GET /expenses' do
      let(:date) { '2017-06-02' }

      context 'when expenses exist on the given date' do
        before do
          allow(ledger).to receive(:records_at_date)
            .with(Date.parse(date))
            .and_return([RecordResult.new(true, 417, nil), RecordResult.new(true, 200, nil)])
        end

        it 'returns the expense records as JSON' do
          get "/expenses/#{date}"

          expect(parsed_body).to include('expense_id' => 417)
          expect(parsed_body).to include('expense_id' => 200)
        end

        it 'responds with a 200' do
          get "/expenses/#{date}"

          expect(last_response.status).to eq 200
        end
      end

      context 'when no expenses exist for the given date' do
        before do
          allow(ledger).to receive(:records_at_date)
            .with(Date.parse(date))
            .and_return([])
        end

        it 'returns an empty JSON array' do
          get "/expenses/#{date}"
          expect(parsed_body).to eq []
        end

        it 'responds with a 200' do
          get "/expenses/#{date}"

          expect(last_response.status).to eq 200
        end
      end
    end
  end
end
