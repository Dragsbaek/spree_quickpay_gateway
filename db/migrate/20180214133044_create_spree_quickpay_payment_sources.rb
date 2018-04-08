class CreateSpreeQuickpayPaymentSources < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_quickpay_payment_sources do |t|
      t.string :payment_id
      t.string :payment_method_name
      t.string :issuer
      t.string :status
      t.string :payment_url
      t.integer :payment_method_id
      t.integer :user_id
    end
  end
end
