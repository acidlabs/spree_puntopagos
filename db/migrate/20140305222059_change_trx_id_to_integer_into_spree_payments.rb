class ChangeTrxIdToIntegerIntoSpreePayments < ActiveRecord::Migration
  def change
    change_column :spree_payments, :trx_id, :integer
  end
end
