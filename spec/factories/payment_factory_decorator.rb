FactoryBot.define do
  factory :quickpay_payment, class: Spree::Payment do
    amount 12.73
    association(:payment_method, factory: :quickpay_gateway)
    association(:source, factory: :quickpay_payment_source)
    order
    state 'checkout'
  end
end