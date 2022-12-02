class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :message_body
      t.belongs_to :phone, index: true
      t.string :status                  # Current status of message (sending|sent|retrying|invalid|inactive)

      t.timestamps
    end
  end
end
