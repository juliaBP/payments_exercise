require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  describe '#index' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    it 'responds with a 200' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns all loans with their outstanding balance' do
      get :index
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json.length).to eq(Loan.count)
      expect(json.none? { |i| i[:outstanding_balance].nil? }).to eq(true)
    end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    context 'the loan is found' do
      it 'responds with a 200' do
        get :show, params: { id: loan.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct loan with its outstanding balance' do
        get :show, params: { id: loan.id }
        data = JSON.parse(response.body, symbolize_names: true)
        expect(data[:id]).to eq(loan.id)
        expect(data[:outstanding_balance].to_i).to eq(loan.outstanding_balance)
      end
    end

    context 'the loan is not found' do
      it 'responds with a 404' do
        get :show, params: { id: 10000 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
