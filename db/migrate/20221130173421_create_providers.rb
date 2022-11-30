class CreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers do |t|
      t.string :endpoint
      t.decimal :weight

      t.timestamps
    end
  end
end
