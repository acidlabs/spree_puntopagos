class AddTrxIdToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :trx_id, :string
  end
end
