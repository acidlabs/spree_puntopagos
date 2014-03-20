# This migration comes from spree_puntopagos (originally 20140116180737)
class AddHstore < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION hstore'
  end

  def down
    execute 'DROP EXTENSION hstore'
  end
end
