# This migration comes from spree_puntopagos (originally 20140305193638)
class AddTrxIdToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :trx_id, :string
  end
end
