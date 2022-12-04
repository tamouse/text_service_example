class CreateActivityLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_logs do |t|
      # This forms a polymorphic relation for any model needing to log some activity
      t.references :loggable, polymorphic: true, null: false, index: true
      t.string  :origin                # Orginating class name of this log entry
      t.boolean :success               # True if this iteration succeeded
      t.boolean :is_valid              # True if this iteration was valid
      t.blob    :data, default: "{}"   # Will hold a JSON string for serioalizing loggable-specific info 

      t.timestamps
    end
  end
end
