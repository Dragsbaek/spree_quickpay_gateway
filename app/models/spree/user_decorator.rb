Spree.user_class.class_eval do
  after_create :create_quickpay_customer

  def create_quickpay_customer
    # Don't create Quickpay customers is spree_auth_devise is not installed.
    return unless defined? Spree::User
    quickpay_gateway = Spree::PaymentMethod.find_by_type 'Spree::Gateway::QuickpayGateway'
    quickpay_customer = quickpay_gateway.create_customer(self)
    update quickpay_customer_id: quickpay_customer.id
  end
end