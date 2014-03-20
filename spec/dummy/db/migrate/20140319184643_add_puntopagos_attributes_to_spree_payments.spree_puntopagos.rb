# This migration comes from spree_puntopagos (originally 20140116181233)
class AddPuntopagosAttributesToSpreePayments < ActiveRecord::Migration
  def up
    add_column :spree_payments, :token,             :string
    add_column :spree_payments, :puntopagos_params, :hstore
  end

  def down
    remove_column :spree_payments, :puntopagos_params
    remove_column :spree_payments, :token
  end
end
