class CreateRulers < ActiveRecord::Migration
  def change
    create_table :rulers do |t|
      t.string   :gvdate,       null: false, limit: 10
      t.string   :fort_group,   null: false, limit: 10
      t.string   :fort_code,    null: false, limit: 10
      t.string   :fort_name,    limit: 100
      t.string   :formal_name,  limit: 100
      t.string   :guild_name,   null: false, limit: 50
      t.string   :source,       null: false, limit: 50
      t.boolean  :full_defense, null: false, default: false
      t.timestamps
    end
    add_index :rulers, :gvdate
    add_index :rulers, :fort_group
    add_index :rulers, [:gvdate, :fort_group]
    add_index :rulers, :guild_name
    add_index :rulers, [:gvdate, :guild_name]
    add_index :rulers, :source
    add_index :rulers, [:gvdate, :fort_code], unique: true
  end
end