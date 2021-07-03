require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:loan_1) { Loan.create!(funded_amount: 100) }
  let!(:payment_1) { Payment.create!(loan: loan_1, amount: 1) }
  let!(:payment_2) { Payment.create!(loan: loan_1, amount: 1) }
  let(:loan_2) { Loan.create!(funded_amount: 100) }
  let!(:payment_3) { Payment.create!(loan: loan_2, amount: 1) }

  describe '#index' do
    it 'responds with a 200' do
      get :index, params: { loan_id: loan_1.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct payments' do
      get :index, params: { loan_id: loan_1.id }
      returned_ids = JSON.parse(response.body, symbolize_names: true).map { |i| i[:id] }
      expect(returned_ids).to include(payment_1.id, payment_2.id)
      expect(returned_ids).not_to include(payment_3.id)
    end
  end

  describe '#show' do
    it 'responds with a 200' do
      get :show, params: { loan_id: loan_1.id, id: payment_1.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct payment' do
      get :show, params: { loan_id: loan_1.id, id: payment_1.id }
      returned_id = JSON.parse(response.body, symbolize_names: true)[:id]
      expect(returned_id).to eq(payment_1.id)
    end

    context 'the loan is not found' do
      it 'responds with a 404' do
        get :show, params: { loan_id: 1000, id: payment_1.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    context 'success' do
      it 'responds with a 201' do
        post :create, params: { loan_id: loan_1.id, amount: 1 }
        expect(response).to have_http_status(:created)
      end

      it 'creates a new payment for the loan' do
        expect{
          post :create, params: { loan_id: loan_1.id, amount: 1 }
        }.to change(loan_1.payments, :count).by(1)
      end

      it 'creates returns the new payment' do
        post :create, params: { loan_id: loan_1.id, amount: 1 }
        returned_id = JSON.parse(response.body, symbolize_names: true)[:id]
        expect(returned_id).to eq(Payment.last.id)
      end
    end

    context 'failure' do
      it 'responds with a 422' do
        post :create, params: { loan_id: loan_1.id, amount: 101 }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors for the payment' do
        post :create, params: { loan_id: loan_1.id, amount: 101 }
        errors = JSON.parse(response.body, symbolize_names: true)
        expect(errors).to include(amount: ["must be greater than 0 and less than or equal to the loan's outstanding balance"])
      end
    end
  end
end
