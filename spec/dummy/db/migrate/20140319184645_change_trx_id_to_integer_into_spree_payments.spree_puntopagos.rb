# This migration comes from spree_puntopagos (originally 20140305222059)
class ChangeTrxIdToIntegerIntoSpreePayments < ActiveRecord::Migration
  def change
    change_column :spree_payments, :trx_id, 'integer USING CAST(trx_id AS integer)'
  end
end
