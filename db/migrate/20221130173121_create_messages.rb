class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :message_body
      t.belongs_to :phone, index: true
      t.belongs_to :last_provider, index: true # Record the last porovider used with this message so it can be retried with another one
      t.string :status                  # Current status of message (sending|sent|delivered|failed|retrying|error)
      t.string :message_guid            # The id returned from the service request, used for lookup with webhook
      t.integer :iteration, default: 0  # Number of times this message has been attempted to send
      t.timestamps
    end
  end
end
