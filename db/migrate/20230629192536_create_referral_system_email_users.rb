class CreateReferralSystemEmailUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :referral_system_email_users do |t|
      t.string  :email
      t.text :access_token
      t.text :refresh_token
      t.datetime :token_expires_at
      t.timestamps
    end
  end
end
