class CreatePostedSituations < ActiveRecord::Migration
  def change
    create_table :posted_situations do |t|
      t.datetime :posted_time, null: false
      t.text     :posted_data, null: false
      t.boolean  :locked,      null: false, default: false
      t.timestamps
    end
    add_index :posted_situations, :posted_time
  end
end
