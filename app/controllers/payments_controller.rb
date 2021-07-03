class PaymentsController < ActionController::API

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'not_found', status: :not_found
  end

  def index
    render json: Payment.where(loan_id: params[:loan_id])
  end

  def show
    render json: Payment.find_by!(id: params[:id], loan_id: params[:loan_id])
  end

  def create
    loan = Loan.find(params[:loan_id])
    payment = Payment.new(loan: loan, amount: params[:amount])
    begin
      ActiveRecord::Base.transaction do
        payment.save!
        new_balance = loan.outstanding_balance - params[:amount].to_f
        loan.update!(outstanding_balance: new_balance)
      end
      render status: :created, json: payment
    rescue ActiveRecord::ActiveRecordError
      render status: :unprocessable_entity, json: payment.errors
    end
  end

end
