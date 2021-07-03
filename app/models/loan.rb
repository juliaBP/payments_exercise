class Loan < ActiveRecord::Base
  has_many :payments

  attr_readonly :funded_amount

  after_initialize :set_outstanding_balance
  validate :funded_amount_ok?
  validate :outstanding_balance_ok?

  def set_outstanding_balance
    return unless new_record?
    self.outstanding_balance = funded_amount
  end

  def funded_amount_ok?
    unless funded_amount > 0
      errors.add(:funded_amount, "must be more than 0")
    end
  end

  def outstanding_balance_ok?
    unless outstanding_balance >= 0 && outstanding_balance <= funded_amount
      errors.add(:outstanding_balance, "must be inclusively between 0 and the funded amount")
    end
  end
end
