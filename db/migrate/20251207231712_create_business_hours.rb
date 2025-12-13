class CreateBusinessHours < ActiveRecord::Migration[7.2]
  def change
    create_table :business_hours do |t|
      t.references :roaster, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :opens_at
      t.time :closes_at
      t.boolean :is_closed, default: false, null: false

      t.timestamps
    end

    add_index :business_hours, [ :roaster_id, :day_of_week ]
  end
end
