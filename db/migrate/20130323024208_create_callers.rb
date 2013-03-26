class CreateCallers < ActiveRecord::Migration
  def change
    create_table :callers do |t|
      t.integer  :situation_id, null: false
      t.string   :revision,     null: false, limit: 30
      t.string   :gvdate,       null: false, limit: 10
      t.string   :fort_group,   null: false, limit: 10
      t.string   :fort_code,    null: false, limit: 10
      t.string   :guild_name,   null: false, limit: 50
      t.string   :reject_name,               limit: 50
      t.timestamps
    end
    add_index :callers, :gvdate
    add_index :callers, :fort_group
    add_index :callers, [:gvdate, :fort_group]
    add_index :callers, :fort_code
    add_index :callers, [:gvdate, :fort_code]
    add_index :callers, :guild_name
    add_index :callers, [:gvdate, :guild_name]
    add_index :callers, :reject_name
    add_index :callers, [:gvdate, :reject_name]
    add_index :callers, [:revision, :fort_code], unique: true
  end
end
