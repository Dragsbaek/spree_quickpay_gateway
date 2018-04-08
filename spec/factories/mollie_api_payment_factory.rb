FactoryBot.define do
  factory :quickpay_api_payment, class: Quickpay::Payment do
    skip_create
    initialize_with { new([]) }
  end
end
