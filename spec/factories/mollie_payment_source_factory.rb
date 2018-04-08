FactoryBot.define do
  factory :quickpay_payment_source, class: Spree::QuickpayPaymentSource do
    payment_method_name 'ideal'
    issuer 'ideal_TESTNL99'
    status 'open'
  end
end
