class AddQuickpayCustomerIdToSpreeUser < ActiveRecord::Migration[5.1]
  def change
    return unless Spree::Gateway::QuickpayGateway.allow_one_click_payments?
    add_column Spree.user_class.table_name, :quickpay_customer_id, :string
  end
end
