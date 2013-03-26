class CreateGuildResults < ActiveRecord::Migration
  def change
    create_table :guild_results do |t|
      t.string :gvdate,     null: false, limit: 10
      t.string :guild_name, null: false, limit: 50
      t.text   :data,       null: false
      t.timestamps
    end
    add_index :guild_results, :gvdate
    add_index :guild_results, :guild_name
    add_index :guild_results, [:gvdate, :guild_name], unique: true
  end
end
