class CreatePhoneErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_errors do |t|
      t.belongs_to :phone, index: true
      t.integer :status_code
      t.text :message
      t.text :raw_body

      t.timestamps
    end
  end
end
