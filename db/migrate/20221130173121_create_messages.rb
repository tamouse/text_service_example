class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.belongs_to :phone, index: true
      t.string :status

      t.timestamps
    end
  end
end
