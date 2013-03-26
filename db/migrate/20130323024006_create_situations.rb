class CreateSituations < ActiveRecord::Migration
  def change
    create_table :situations do |t|
      t.string   :revision,    null: false, limit: 30
      t.string   :gvdate,      null: false, limit: 10
      t.datetime :update_time, null: false
      t.timestamps
    end
    add_index :situations, :revision, unique: true
    add_index :situations, :gvdate
  end
end
