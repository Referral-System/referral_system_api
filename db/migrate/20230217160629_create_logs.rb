class CreateLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.string  :view
      t.string  :action
      t.integer :user_id
      t.string :user_name
      t.json :request_payload
      t.string :message
      t.boolean :has_error
      t.timestamps
    end
  end
end
