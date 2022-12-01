class CreateMessageTries < ActiveRecord::Migration[7.0]
  def change
    create_table :message_tries do |t|
      t.belongs_to :message, index: true
      t.string :statuw
      t.integer :try_number
      t.string :response_status_code
      t.text :response_message
      t.text :response_raw_body

      t.timestamps
    end
  end
end
