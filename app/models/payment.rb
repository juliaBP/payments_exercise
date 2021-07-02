class Payment < ActiveRecord::Base
  belongs_to :loan

  validates :loan, presence: true
  validate :for_outstanding_balance

  def for_outstanding_balance
    unless amount > 0 && amount <= loan.outstanding_balance
      errors.add(:amount, "must be greater than 0 and less than or equal to the loan's outstanding balance")
    end
  end
end
