class CreateProviderErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_errors do |t|
      t.belongs_to :provider, index: true
      t.string :status
      t.boolean :active
      t.text :message
      t.text :raw_body

      t.timestamps
    end
  end
end
