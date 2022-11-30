class CreatePhones < ActiveRecord::Migration[7.0]
  def change
    create_table :phones do |t|
      t.string :number
      t.string :status
      t.boolean :valid

      t.timestamps
    end
  end
end
