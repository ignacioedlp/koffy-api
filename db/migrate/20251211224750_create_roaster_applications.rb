class CreateRoasterApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :roaster_applications do |t|
      t.string :email, null: false
      t.string :roaster_name, null: false
      t.string :full_name, null: false
      t.text :comment
      t.string :website_url
      t.string :phone_number
      t.string :type_of_business, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
