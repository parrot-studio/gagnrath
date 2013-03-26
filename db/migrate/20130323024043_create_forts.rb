class CreateForts < ActiveRecord::Migration
  def change
    create_table :forts do |t|
      t.integer  :situation_id, null: false
      t.string   :revision,     null: false, limit: 30
      t.string   :gvdate,       null: false, limit: 10
      t.string   :fort_group,   null: false, limit: 10
      t.string   :fort_code,    null: false, limit: 10
      t.string   :fort_name,    limit: 100
      t.string   :formal_name,  limit: 100
      t.string   :guild_name,   null: false, limit: 50
      t.datetime :update_time,  null: false
      t.timestamps
    end
    add_index :forts, :situation_id
    add_index :forts, :gvdate
    add_index :forts, :fort_group
    add_index :forts, [:gvdate, :fort_group]
    add_index :forts, :guild_name
    add_index :forts, [:gvdate, :guild_name]
    add_index :forts, [:revision, :fort_code], unique: true
  end
end
