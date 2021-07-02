class AddOutstandingBalanceToLoans < ActiveRecord::Migration[5.2]
  def up
    add_column :loans, :outstanding_balance, :decimal, precision: 8, scale: 2
  end

  def down
    remove_column :loans, :outstanding_balance
  end
end
