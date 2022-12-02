class CreatePhones < ActiveRecord::Migration[7.0]
  def change
    create_table :phones do |t|
      t.string :number                  # The phone number receiving the message
      t.string :status                  # Current status: active|inactive|invalid

      t.timestamps
    end
  end
end
